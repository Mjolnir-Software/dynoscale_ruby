require 'dynoscale_agent/api_wrapper'
require 'dynoscale_agent/recorder'

module DynoscaleAgent
  class Reporter
    include Singleton

    REPORT_PUBLISH_FREQ = 2.minutes
    REPORT_PUBLISH_RETRY_FREQ = 15.seconds

    def self.start!(env, recorder)
      is_dev = ENV['DYNOSCALE_DEV'] == 'true'
      dyno = is_dev ? "dev.1" : ENV['DYNO']
      @@api_wrapper = ApiWrapper.new(dyno, ENV['DYNOSCALE_URL'], ENV['HEROKU_APP_NAME'])

      @@reporter_thread ||= Thread.start do
      	loop do
          if recorder.publishable_reports.any?
            # publish measurements if its been a minute
            @@api_wrapper.publish_reports(recorder.publishable_reports) do |success?, published_reports|
              if success?
              	recorder.remove_published_reports!(published_reports)
                sleep REPORT_PUBLISH_FREQ
              else
              	# last publish failed, retry sooner
              	sleep REPORT_PUBLISH_RETRY_FREQ
              end
            end
          end
        end
      end
    end

    def self.running?
      !!@@reporter_thread&.alive? 
    end
  end
end