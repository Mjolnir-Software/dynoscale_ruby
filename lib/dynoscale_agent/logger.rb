require 'logger'

module DynoscaleAgent
  module Logger

    def self.logger
      @@logger ||= if defined?(Rails)
        Rails.logger
      else
        ::Logger.new(STDOUT)
      end
      if ENV['DYNOSCALE_DEV']
      	@@logger.level = ::Logger::DEBUG
      else
        @@logger.level = ::Logger::WARN
      end
      @@logger
    end
  end
end