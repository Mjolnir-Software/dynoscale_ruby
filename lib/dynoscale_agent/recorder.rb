require 'dynoscale_agent/report'
require 'dynoscale_agent/request_calculator'

module DynoscaleAgent
  class Recorder
    include Singleton

    def self.record!(env)
      is_dev = ENV['DYNOSCALE_DEV'] == 'true'
      dyno = is_dev ? "dev.1" : ENV['DYNO']
      request_calculator ||= RequestCalculator.new(env)
      

      queue_time = request_calculator.request_queue_time
      puts "Request Time #{queue_time}"
      current_time = Time.now

      @@current_report ||= Report.new(current_time + REPORT_PUBLISH_FREQ)
      
      if queue_time
        @@current_report.add_measurement(current_time, queue_time)
        puts "Enqueue measurement: #{[current_time.to_i, queue_time]}"
      end

      @@publishable_reports ||= []
      if @@current_report.ready_to_publish?
      	@@publishable_reports << @@current_report
      	@@current_report = nil
      end
    end

    def self.publishable_reports
      @@publishable_reports || []
    end

    def self.remove_published_reports!(reports)
      reports_to_delete_publish_timestamp = published_reports.map(&:publish_timestamp)
      @@publishable_reports.delete_if{|published_report| reports_to_delete_publish_timestamp.include?(published_report.publish_timestamp) }
    end
  end
end