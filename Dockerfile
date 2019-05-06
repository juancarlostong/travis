FROM ruby:2.6.0
COPY Gemfile /
RUN bundle install --verbose
