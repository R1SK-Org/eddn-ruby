FROM ruby:3.0

RUN apt update && apt install -y \
  git \
  libzmq3-dev

# Throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["bash"]
