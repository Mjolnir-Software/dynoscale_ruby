require 'dynoscale_agent/middleware'

module DynoscaleAgent
  class Railtie < Rails::Railtie
    initializer "dynoscale.configure_rails_initialization" do |app|
      app.middleware.insert_before Rack::Runtime, ::DynoscaleAgent::Middleware
    end
  end
end
