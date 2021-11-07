# frozen_string_literal: true

require 'dynoscale_agent/request_calculator'
require 'dynoscale_agent/reporter'

module DynoscaleAgent
  class Middleware

    MEASUREMENT_TTL = 5 # minutes


    def initialize(app)
      @app = app
    end

    def call(env)
      is_dev = ENV['DYNOSCALE_DEV'] == 'true'
      return @app.call(env) if ENV['SKIP_DYNASCALE_AGENT']
      return @app.call(env) unless is_dev || ENV['DYNO']&.split(".")&.last == "1"
      
      recorder = Recorder.instance
      recorder.record!
      Reporter.start!(env, recorder) if Reporter.running?

      @app.call(env)
    end
  end
end
