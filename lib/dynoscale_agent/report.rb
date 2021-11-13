require 'dynoscale_agent/measurement'

module DynoscaleAgent
  class Report

  	REPORT_TTL = 5 * 60 # minutes

    attr_reader :publish_timestamp, :measurements

  	def initialize(publish_timestamp)
      @measurements = []
      @publish_timestamp = publish_timestamp
  	end

  	def add_measurement(current_time = Time.now, queue_time)
      @measurements << Measurement.new(current_time.to_i, queue_time)
  	end

  	def add_measurements(measurements)
      @measurements.unshift(*measurements)
  	end

    def ready_to_publish?(current_time = Time.now)
      @measurements.any? && publish_timestamp < current_time
    end

  	def expired?(current_time = Time.now)
      publish_timestamp < (current_time - REPORT_TTL)
  	end

  	def to_csv
      @measurements.reduce(""){|t, m| "#{t}#{m.timestamp},#{m.queue_time}\n"}
  	end
  end
end