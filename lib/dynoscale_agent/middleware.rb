# frozen_string_literal: true

require 'dynoscale_agent/request_calculator'
require 'dynoscale_agent/reporter'
require 'dynoscale_agent/recorder'
require 'dynoscale_agent/worker/sidekiq'
require 'dynoscale_agent/worker/resque'

module DynoscaleAgent
  class Middleware

    MEASUREMENT_TTL = 5 # minutes


    def initialize(app)
      @app = app
    end

    def call(env)
      is_dev = ENV['DYNOSCALE_DEV'] == 'true'
      dyno = is_dev ? "dev.1" : ENV['DYNO']

      unless ENV['DYNOSCALE_URL']
        puts "Missing DYNOSCALE_URL environment variable"
        return @app.call(env)
      end 
      return @app.call(env) if ENV['SKIP_DYNASCALE_AGENT']
      return @app.call(env) unless is_dev || ENV['DYNO']&.split(".")&.last == "1"

      request_calculator = RequestCalculator.new(env)
      workers =  DynoscaleAgent::Worker.constants.select{|c| DynoscaleAgent::Worker.const_get(c).is_a? Class }.map{|c| DynoscaleAgent::Worker.const_get(c) }
      Recorder.record!(request_calculator, workers)

      api_wrapper = DynoscaleAgent::ApiWrapper.new(dyno, ENV['DYNOSCALE_URL'], ENV['HEROKU_APP_NAME'])
      Reporter.start!(Recorder, api_wrapper) unless Reporter.running?


      @app.call(env)
    end
  end
end
