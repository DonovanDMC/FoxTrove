module Scraper
  # https://gist.github.com/upbit/6edda27cb1644e94183291109b8a5fde
  # https://github.com/upbit/pixivpy/wiki/Sniffer-for-iOS-6.x---Common-API
  # https://gist.github.com/ZipFile/3ba99b47162c23f8aea5d5942bb557b1
  # https://github.com/upbit/pixivpy/blob/master/pixivpy3/api.py
  class Pixiv < Base
    API_BASE_URL = "https://app-api.pixiv.net/v1".freeze
    LOGIN_URL = "https://app-api.pixiv.net/web/v1/login".freeze
    REDIRECT_URI = "https://app-api.pixiv.net/web/v1/users/auth/pixiv/callback".freeze
    AUTH_TOKEN_URL = "https://oauth.secure.pixiv.net/auth/token".freeze
    OS_VERSION = "14.6".freeze
    APP_VERSION = "7.13.3".freeze
    USER_AGENT = "PixivIOSApp/#{APP_VERSION} (iOS #{OS_VERSION}; iPhone13,2)".freeze
    CLIENT_ID = "MOBrBDS8blbauoSck0ZfDbtuzpyT".freeze
    CLIENT_SECRET = "lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj".freeze
    PER_PAGE = 30

    def init
      @access_token = Cache.fetch("pixiv-token", 55.minutes) do
        fetch_access_token
      end
      @offset = 0
    end

    def self.enabled?
      Config.pixiv_user.present? && Config.pixiv_pass.present?
    end

    def fetch_next_batch
      json = make_request("user/illusts", {
        user_id: @api_identifier,
        type: "illust",
        offset: @offset,
      })
      @offset += PER_PAGE
      end_reached unless json["next_url"]
      json["illusts"]
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["id"]
      s.title = submission["title"]
      s.description = submission["caption"]
      created_at = extract_timestamp submission
      s.created_at = created_at

      if submission.dig("meta_single_page", "original_image_url")
        s.add_file({
          url: submission["meta_single_page"]["original_image_url"],
          created_at: created_at,
          identifier: 0,
        })
      else
        submission["meta_pages"].each.with_index do |entry, index|
          s.add_file({
            url: entry["image_urls"]["original"],
            created_at: created_at,
            identifier: index,
          })
        end
      end
      s
    end

    def extract_timestamp(submission)
      DateTime.parse submission["create_date"]
    end

    # The url identifier is already the api identifier
    def fetch_api_identifier
      @url_identifier
    end

    def make_request(endpoint, query = {})
      response = HTTParty.get("#{API_BASE_URL}/#{endpoint}", query: query, headers: {
        **headers,
        Authorization: "Bearer #{@access_token}",
      })
      JSON.parse response.body
    end

    private

    def fetch_access_token
      SeleniumWrapper.driver(with_performance: true) do |driver|
        code_verifier = urlsafe_b64 SecureRandom.base64(32)
        code_challenge = urlsafe_b64 Digest::SHA256.base64digest(code_verifier)

        login_params = {
          code_challenge: code_challenge,
          code_challenge_method: "S256",
          client: "pixiv-android",
        }

        driver.navigate.to "#{LOGIN_URL}?#{login_params.to_query}"
        wait = Selenium::WebDriver::Wait.new(timeout: 10)
        wait.until { driver.find_element(css: "#LoginComponent [autocomplete='username']") }.send_keys Config.pixiv_user
        driver.find_element(css: "#LoginComponent [autocomplete='current-password']").send_keys Config.pixiv_pass
        driver.find_element(css: "#LoginComponent .signup-form__submit").click

        code = nil
        wait.until do
          logs = driver.logs.get("performance")
          code = fetch_code_from_logs logs
          true if code
        end
        response = HTTParty.post(AUTH_TOKEN_URL, headers: headers, body: {
          client_id: CLIENT_ID,
          client_secret: CLIENT_SECRET,
          code: code,
          code_verifier: code_verifier,
          grant_type: "authorization_code",
          unclude_policy: true,
          redirect_uri: REDIRECT_URI,
        })
        response["access_token"]
      end
    end

    def headers
      {
        "User-Agent": USER_AGENT,
        "App-OS-Version": OS_VERSION,
        "App-OS": "ios",
      }
    end

    def urlsafe_b64(input)
      input.tr("+/", "-_").tr("=", "")
    end

    def fetch_code_from_logs(logs)
      logs.each do |entry|
        message = JSON.parse(entry.message)["message"]
        next if message["method"] != "Network.requestWillBeSent"

        url = message.dig("params", "documentURL")
        uri = Addressable::URI.parse url
        return uri.query_values["code"] if uri.scheme == "pixiv"
      end
      nil
    end
  end
end
