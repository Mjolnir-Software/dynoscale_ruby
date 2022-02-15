# Dynoscale Agent

#### Simple yet efficient scaling agent for Ruby/Rails apps on Heroku

## Getting Started

1. Add __dynoscale__ to your app on Heroku: `heroku addons:create dscale`
2. Add the agent Gem to your Gemfile: `gem 'dynoscale_agent'`
3. Run bundle:  `bundle install`
4. Profit! (Literally, this will save you money 😏

The environment variable `DYNOSCALE_URL` must be set in order for your application to communicate with Dynoscale Servers.

## Non-Rails Rack Based Apps

In addition to the above steps, you will need to `require 'dynoscale_agent/middleware'` and add the `DynoscaleAgent::Middleware` before the `Rack::Runtime` in your application.

## Data Shared with Dynoscale

* Dyno Name
* Application Name
* queue measurment data for web and worker dynos

## Worker Adapter

In addition to Web scaling, Dynoscale collects data on Worker jobs too. At this time Sidekiq and Resque are currently supported.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Mjolnir-Software/dynoscale_agent.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT)
