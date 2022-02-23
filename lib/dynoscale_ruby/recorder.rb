require 'dynoscale_ruby/report'
require 'dynoscale_ruby/request_calculator'
require 'singleton'
require 'dynoscale_ruby/logger'

module DynoscaleRuby
  class Recorder
    include Singleton
    extend Logger

    REPORT_RECORDING_FREQ = 5 #seconds

    def self.record!(request_calculator, workers)
      is_dev = ENV['DYNOSCALE_DEV'] == 'true'
      dyno = is_dev ? "dev.1" : ENV['DYNO']
      
      queue_time = request_calculator.request_queue_time
      current_time = Time.now

      @@current_report ||= Report.new(current_time + REPORT_RECORDING_FREQ)
      
      if queue_time
        @@current_report.add_measurement(current_time, queue_time, 'web', nil)
        Logger.logger.debug "Web measurement #{current_time}, #{queue_time} recorded in report."
      end

      workers.each do |worker|
        if worker.enabled?
          queue_latencies = worker.queue_latencies
          queue_latencies.each do |queue, latency, depth|
            @@current_report.add_measurement(current_time, latency, "#{worker.name}:#{queue}", nil)
            Logger.logger.debug "#{worker.name.capitalize} worker measurement #{current_time}, #{latency} recorded in report."
          end
        end
      end

      @@reports ||= {}
      @@reports[@@current_report.publish_timestamp] = @@current_report
      @@reports.values
    end

    def self.reports
      @@reports ||= {}
      @@reports.values || []
    end

    def self.remove_published_reports!(reports)
      reports.each do |report|
        @@current_report = nil if report.publish_timestamp == @@current_report.publish_timestamp
        @@reports.delete(report.publish_timestamp)
      end
    end
  end
end
