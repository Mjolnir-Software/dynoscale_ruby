# frozen_string_literal: true

require 'dynoscale_ruby/middleware'

module DynoscaleAgent
  class Railtie < Rails::Railtie
    initializer "dynoscale_agent.middleware" do |app|
      app.middleware.insert_before Rack::Runtime, DynoscaleRuby::Middleware
    end
  end
end
