FROM ruby:3.2.2-alpine3.18 as ruby-builder

RUN apk --no-cache add build-base postgresql15-dev

COPY Gemfile Gemfile.lock ./
RUN gem i foreman && bundle install \
 && rm -rf /usr/local/bundle/cache/*.gem \
 && find /usr/local/bundle/gems/ -name "*.c" -delete \
 && find /usr/local/bundle/gems/ -name "*.o" -delete

ARG COMPOSE_PROFILES
RUN if [[ $COMPOSE_PROFILES == *"solargraph"* ]]; then \
  bundle exec yard gems; \
fi

FROM node:18-alpine3.18 as node-builder

WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && corepack prepare --activate && pnpm install

FROM ruby:3.2.2-alpine3.18

WORKDIR /app

RUN apk --no-cache add \
  tzdata git \
  postgresql15-client \
  vips ffmpeg

RUN git config --global --add safe.directory /app

# Setup node and pnpm
ENV PATH=/node_modules/.bin:$PATH
COPY --from=node-builder /usr/lib /usr/lib
COPY --from=node-builder /usr/local/share /usr/local/share
COPY --from=node-builder /usr/local/lib /usr/local/lib
COPY --from=node-builder /usr/local/include /usr/local/include
COPY --from=node-builder /usr/local/bin /usr/local/bin
COPY --from=node-builder /root/.cache/node /root/.cache/node

# Copy gems and js packages
COPY --from=node-builder /app/node_modules /node_modules
COPY --from=ruby-builder /usr/local/bundle /usr/local/bundle

RUN echo "IRB.conf[:USE_AUTOCOMPLETE] = false" > ~/.irbrc
