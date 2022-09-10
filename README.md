# Developing with Docker and RubyMine

The purpose of this project is to demonstrate how to develop with Docker and RubyMine. Some goals:

* We must not install ruby on the host machine
* We must be able to debug and test the app using the IDE (RubyMine)
* It must be simple for other developers to spin up their own dev environments


Some pre-requisites:

* RubyMine _(I tested with 2022.2.1)_
* Docker _(I tested with 20.10.16)_


## Prepping our app

Let's start off by creating the following files in the project's `app/` directory:

`app/hello_world.rb`:
```ruby
require 'time'

def hello
  puts 'Hello, world.'
  puts "Current Time: #{Time.now.iso8601}"
  puts "Ruby Version #{RUBY_VERSION}"
end

if __FILE__ == $0
  hello
end
```


`app/Gemfile`:
```ruby
source "https://rubygems.org"

ruby "2.7.6"

# Gems required for debugging
gem 'debase'
gem 'ruby-debug-ide'
```

`app/Dockerfile`:
```dockerfile
FROM ruby:2.7.6-buster
WORKDIR /usr/src/app
COPY . .
RUN bundle install
CMD ["ruby", "hello_world.rb"]
```

Next, let's set up a docker-compose file.  This allows us to automatically build a docker image from the `app/Dockerfile`, and mount our `app/` directory as a volume in the container.

`docker-compose.yml`:
```
version: "3.9"
services:
  app:
    build: ./app
    volumes:
      - ./app:/usr/src/app
```


