FROM ruby:2.3.1
COPY Gemfile /
RUN bundle install --verbose
