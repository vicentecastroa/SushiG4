FROM ruby:2.5.1

ENV LANG C.UTF-8

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev software-properties-common

# Node.js
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y nodejs

# yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -\
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y yarn

ENV APP_HOME /SushiG4

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

ADD Gemfile $APP_HOME/Gemfile
ADD Gemfile.lock $APP_HOME/Gemfile.lock
RUN bundle install --jobs=3 --retry=3

ADD . $APP_HOME

# # Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]