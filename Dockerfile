FROM ruby:latest
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs git freeipmi
RUN mkdir /Rails_DCIM_Portal
WORKDIR /Rails_DCIM_Portal
ADD Gemfile /Rails_DCIM_Portal/Gemfile
ADD Gemfile.lock /Rails_DCIM_Portal/Gemfile.lock
RUN bundle install
ADD . /Rails_DCIM_Portal
