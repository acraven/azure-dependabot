FROM ruby:2.6.2-alpine
WORKDIR /app

RUN apk add --updat build-base

COPY Gemfile .
RUN bundle install

# DO NOT COMMIT YOUR AZURE DEVOPS PAT TO THE REPO
ENV SYSTEM_ACCESSTOKEN YOUR_AZURE_DEVOPS_PAT

COPY . .
RUN bundle exec ruby ./update.rb