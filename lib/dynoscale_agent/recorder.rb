require 'dynoscale_agent/report'
require 'dynoscale_agent/request_calculator'
require 'singleton'

module DynoscaleAgent
  class Recorder
    include Singleton

    REPORT_RECORDING_FREQ = 1 * 60 # minutes

    def self.record!(request_calculator, workers)
      is_dev = ENV['DYNOSCALE_DEV'] == 'true'
      dyno = is_dev ? "dev.1" : ENV['DYNO']
      
      queue_time = request_calculator.request_queue_time
      current_time = Time.now

      @@current_report ||= Report.new(current_time + REPORT_RECORDING_FREQ)
      
      if queue_time
        @@current_report.add_measurement(current_time, queue_time, 'web', nil)
      end

      workers.each do |worker|
        if worker.enabled?
          queue_latencies = worker.queue_latencies
          queue_latencies.each do |queue, latency, depth|
            @@current_report.add_measurement(current_time, queue_time, "#{worker.name}-#{queue}", nil)
          end
        end
      end

      @@reports ||= {}
      @@reports[@@current_report.publish_timestamp] = @@current_report
      @@reports.values
    end

    def self.reports
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