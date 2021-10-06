# frozen_string_literal: true

module DynascaleAgent
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      puts "Found me"
      @app.call(env)
    end
  end
end
