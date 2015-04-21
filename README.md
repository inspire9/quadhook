# Quadhook

A Rack endpoint for handling Quaderno webhooks, and fires an ActiveSupport notification for each succesful request.

[![Build Status](https://travis-ci.org/inspire9/quadhook.svg)](https://travis-ci.org/inspire9/quadhook)
[![Code Climate](https://codeclimate.com/github/inspire9/quadhook/badges/gpa.svg)](https://codeclimate.com/github/inspire9/quadhook)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'quadhook', '~> 0.0.1'
```

## Usage

Mount an instance of `Quadhook::Endpoint` to your preferred route. In a Rails app, that'd look something like this:

```ruby
post '/quaderno/webhook', to: Quaderno::Endpoint.new(
  ENV['QUADERNO_AUTH_KEY'],
  ENV['QUADERNO_HOOK_URI']
)
```

Then, handle the notifications using something like the following (which would probably go in an initialiser for a Rails app):

```ruby
ActiveSupport::Notifications.subscribe(
  'notification.quaderno.webhook'
) do |*args|
  event = ActiveSupport::Notifications::Event.new *args
  # use event.payload[:event_type] and event.payload[:data] however you like.
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Firstly, please note the Code of Conduct for all contributions to this project. If you accept that, then the steps for contributing are probably something along the lines of:

1. Fork it ( https://github.com/inspire9/quadhook/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Licence

Copyright (c) 2015, Quadhook is developed and maintained by [Inspire9](http://development.inspire9.com), and is released under the open MIT Licence.
