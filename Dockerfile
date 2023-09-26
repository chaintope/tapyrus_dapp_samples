FROM ruby:3.2.2

ENV LANG=C.UTF-8
ENV TZ=Asia/Tokyo

RUN apt-get update -qq \
    && apt-get install -y nodejs postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp

COPY entrypoint.sh /usr/bin/

RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
