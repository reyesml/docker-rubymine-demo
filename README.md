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


## Configure Docker-Compose as our Remote SDK
In RubyMine, go to `prefernces > languages & frameworks > ruby sdk & gems`, and add our docker-compose file as the source for a new remote interpreter:

![Image showing RubyMine SDK Options with "Remote Interpreter or Version Manager" selected](images/adding_sdk_01.jpg?raw=true "SDK Options")

![Image showing the Docker Compose Remote SDK configuration](images/adding_sdk_02.jpg "Docker Compose Remote SDK")

![Image showing RubyMineSDK Options with the newly added Remote Interpreter selected](images/adding_sdk_03.jpg)

Once the Remote SDK has been configured, you should notice that a `app/Gemfile.lock` file was generated.  This is thanks to the `RUN bundle install` specified in our `app/Dockerfile`, and because we've mounted `app/` as a volume within our container using Docker Compose.






## Running and Debugging the App

Now that we've configured docker-compose as our remote SDK, we should be able to run our app from the IDE.  Open the `app/hello_world.rb` file in the RubyMine editor.  Right-click anywhere in that file, and select "run":

![Image showing hello_world.rb open with the "run" dialog option selected](images/running_app_01.jpg)

You should receive output similar to the screenshot below.


![Image with the following text: "Hello, world. <br> 2022-09-10T23:48:26+00:00 <br> 2.7.6](images/running_app_02.jpg)

Notice the Ruby version in the screeshot above.  It should match the version specified in the`app/Dockerfile`.  If it doesn't match (or the app doesn't run), double-check that the remote sdk is selected within the "Ruby SDK and Gems" preferences.

You should also be able to set a breakpoint and debug your app using the Remote SDK.  Again, the RUBY_VERSION in the debugging output should match the version specified in our `app/Dockerfile`:

![Image demonstrating RubyMine debugging hello_world.rb within a docker container](images/debugging_app_01.jpg)


## Adding Tests

Let's setup [rspec](https://rspec.info/) to our project.  First, we need to add `gem 'rspec'` to our `app/Gemfile` :

```ruby
source "https://rubygems.org"

ruby "2.7.6"

# Gems required for debugging
gem 'debase'
gem 'ruby-debug-ide'

gem 'rspec'
```

Next, we'll run `bundle install` against our remote SDK.  To do this, open the Gemfile in RubyMine, hover over the rspec gem, and select "Execute 'bundle install' in running container and rebuild Docker Image":

![Image demonstrating how to run bundle install against the remote SDK](images/adding_tests_01.jpg)

_Note: Running `bundle install` via different means may not install the gems in the container referenced by the Remote SDK.  This results in a loss of intellisense for newly added gems._

Once the bundle install has finished, open a terminal in the root of the project, then run:

`docker compose run --rm app rspec --init`

You should see new `app/.rspec` and `app/spec/spec_helper.rb` files added to the repository.

Next, let's add a simple test:

`app/rspec/hello_world_spec.rb`:
```ruby
require_relative '../hello_world'

RSpec.describe "hello" do
  it "can run the tests" do
    hello
    expect(true).to eq true
  end
end
```

If you open `app/rspec/hello_world_spec.rb` in rubymine, you should be able to run and debug the application using the gutters of the test file:

![Image showing the "Run" buttons in the gutter of hello_world_spec.rb](images/adding_tests_02.jpg)

![Image demonstrating a debug run of hello_world_spec.rb](images/adding_tests_03.jpg)

Notice again how the ruby version matches the version specified in our Dockerfile.


