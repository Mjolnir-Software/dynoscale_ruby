require 'dynoscale_agent/api_wrapper'
require 'dynoscale_agent/recorder'

module DynoscaleAgent
  class Reporter
    include Singleton

    REPORT_PUBLISH_FREQ = 30.seconds
    REPORT_PUBLISH_RETRY_FREQ = 15.seconds

    def self.start!(env, recorder)
      is_dev = ENV['DYNOSCALE_DEV'] == 'true'
      dyno = is_dev ? "dev.1" : ENV['DYNO']

      @@api_wrapper ||= DynoscaleAgent::ApiWrapper.new(dyno, ENV['DYNOSCALE_URL'], ENV['HEROKU_APP_NAME'])

      @@reporter_thread ||= Thread.start do
      	loop do
          if recorder.reports.any?(&:ready_to_publish?)
            @@api_wrapper.publish_reports(recorder.reports) do |success, published_reports|
              if success
              	recorder.remove_published_reports!(published_reports)
                sleep REPORT_PUBLISH_FREQ
              else
              	sleep REPORT_PUBLISH_RETRY_FREQ
              end
            end
          else
            sleep REPORT_PUBLISH_FREQ
          end
        end
      end
    end

    def self.running?
      @@reporter_thread ||= nil
      !!@@reporter_thread && @@reporter_thread.alive? 
    end
  end
end