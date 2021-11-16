require 'logger'

module DynoscaleAgent
  module Logger
    def logger
      @logger ||= if defined?(Rails)
        Rails.logger
      else
        ::Logger.new(STDOUT)
      end
      assign_level
      @logger
    end

    private

    def assign_level
      if ENV['DYNOSCALE_DEV']
      	@logger.level = Logger::DEBUG
      else
        @logger.level = Logger::WARN
      end
    end
  end
end