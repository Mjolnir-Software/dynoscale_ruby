# frozen_string_literal: true

require 'dynoscale_agent/middleware'

module DynoscaleAgent
  class Railtie < Rails::Railtie
    initializer "dynoscale_agent.middleware" do |app|
      app.middleware.insert_before Rack::Runtime, DynoscaleAgent::Middleware
    end
  end
end
