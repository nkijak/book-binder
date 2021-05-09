FROM ruby:2.6.7-alpine3.13

LABEL maintainer='Makersend.com <info@makersend.com>'

RUN apk update && apk --no-cache add \
    --virtual build-dependencies \
    build-base \
    python3 \
    curl \
    gcc \
    libc-dev \
    git

RUN gem install bundler
    
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py

ENV     BOOK_HOME /binder
RUN     mkdir $BOOK_HOME
WORKDIR $BOOK_HOME

COPY Gemfile Gemfile.lock $BOOK_HOME/

ENV BUNDLE_PATH $BOOK_HOME
ENV GEM_PATH    $BOOK_HOME
ENV GEM_HOME    $BOOK_HOME

RUN bundle install

COPY buildDistro.sh $BOOK_HOME/
CMD $BOOK_HOME/buildDistro.sh
