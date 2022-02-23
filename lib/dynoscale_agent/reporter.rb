require 'dynoscale_agent/api_wrapper'
require 'dynoscale_agent/recorder'
require 'dynoscale_agent/logger'

module DynoscaleAgent
  class Reporter
    include Singleton
    extend Logger

    # Production delays
    REPORT_PUBLISH_FREQ = 30 # seconds
    REPORT_PUBLISH_RETRY_FREQ = 15 #seconds

    def self.start!(recorder, api_wrapper, break_after_first_iteration: false)
      @@reporter_thread ||= Thread.start do
      	loop do
          if recorder.reports.any?(&:ready_to_publish?)
            api_wrapper.publish_reports(recorder.reports) do |success, published_reports, config|
              if success
              	recorder.remove_published_reports!(published_reports)
                @@config = config
                Logger.logger.debug "Report publish was successful"
                sleep report_publish_freq
              else
                Logger.logger.error "Report publish failed"
              	sleep report_publish_retry_freq
              end
            end
          else
            sleep report_publish_retry_freq
          end
          break if break_after_first_iteration
        end
      end
    end

    def self.running?
      @@reporter_thread ||= nil
      !!@@reporter_thread && @@reporter_thread.alive? 
    end

    def self.report_publish_freq
      is_dev = ENV['DYNOSCALE_DEV'] == 'true'
      if is_dev
        0
      elsif @@config && @@config['publish_frequency']
        @@config['publish_frequency']&.to_i || REPORT_PUBLISH_FREQ
      else
        REPORT_PUBLISH_FREQ
      end
    end

    def self.report_publish_retry_freq
      is_dev = ENV['DYNOSCALE_DEV'] == 'true'
      is_dev ? 0 : REPORT_PUBLISH_RETRY_FREQ
    end
  end
end
