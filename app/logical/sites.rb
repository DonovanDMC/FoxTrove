# frozen_string_literal: true

module Sites
  module_function

  def from_enum(value)
    ENUM_MAP[value]
  end

  def from_url(url)
    begin
      uri = Addressable::URI.parse url
    rescue Addressable::URI::InvalidURIError
      return nil
    end

    ALL.lazy.filter_map do |definition|
      definition.match_for uri
    end.first
  end

  def for_domain(domain)
    ALL.find do |definition|
      definition.handles_domain? domain
    end
  end

  def download_file(outfile, url, definition = nil)
    # produces the right uri for all of these:
    # https://d.furaffinity.net/art/peyzazhik/1629082282/1629082282.peyzazhik_%D0%B7%D0%B0%D0%BB%D0%B8%D0%B2%D0%B0%D1%82%D1%8C-%D0%B3%D0%B8%D1%82%D0%B0%D1%80%D1%83.jpg
    # https://d.furaffinity.net/art/peyzazhik/1629082282/1629082282.peyzazhik_заливать-гитару.jpg
    # https://d.furaffinity.net/art/nawka/1642391380/1642391380.nawka__sd__kwaza_and_hector_[final].jpg
    # https://d.furaffinity.net/art/fr95/1635001690/1635001679.fr95_co＠f-r9512.png  (notice the different @ sign)
    unencoded = Addressable::URI.unencode(url)
    escaped = Addressable::URI.escape(unencoded)
    uri = Addressable::URI.parse(escaped)
    # https://www.newgrounds.com/art/view/nawka/comm-soot-and-lunamew
    # Secondary image url is missing the scheme, just assume https in those cases
    uri.scheme = "https" unless uri.scheme
    raise Addressable::URI::InvalidURIError, "scheme must be http(s)" unless uri.scheme.in?(%w[http https])
    raise Addressable::URI::InvalidURIError, "host must be set" if uri.host.blank?

    definition ||= for_domain(uri.domain)
    headers = definition&.download_headers || {}
    response = HTTParty.get(uri, { headers: headers }) do |chunk|
      outfile.write(chunk)
    end
    outfile.rewind
    response
  end

  ALL = Definitions.constants.map { |name| Definitions.const_get(name).new }

  ENUM_MAP = ALL.index_by(&:enum_value).freeze
end
