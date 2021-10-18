# frozen_string_literal: true

require 'dynoscale_agent/request_calculator'
require 'uri'
require 'net/http'

module DynoscaleAgent
  class Middleware

    MEASUREMENT_TTL = 5 # minutes
    REPORT_PUBLISH_FREQ = 2 # minutes
    REPORT_PUBLISH_RETRY_FREQ = 0.25 # minutes

    def initialize(app)
      @app = app
    end

    def call(env)
      return @app.call(env) if ENV['SKIP_DYNASCALE_AGENT']
      request_calculator = RequestCalculator.new(env)
      @@measurements ||= []

      queue_time = request_calculator.request_queue_time
      puts "Request Time #{queue_time}"
      current_time = Time.now
      @@next_report ||= current_time + REPORT_PUBLISH_FREQ * 60
      puts "Next Report #{@@next_report}"

      if queue_time
        @@measurements.push([current_time.to_i, queue_time])
        puts "Enqueue measurement: #{[current_time.to_i, queue_time]}, Measurement Count: #{@@measurements.length}"
      end

      if @@measurements.any? && @@next_report < current_time
        # publish measurements if its been a minute
	report = @@measurements.slice!(0..-1)
        url = URI("#{ENV['DYNOSCALE_URL']}/api/v1/report")
        if url.scheme == "http"
	  http = Net::HTTP.new(url.host, url.port)
	  request = Net::HTTP::Post.new(url)
        else
          https = Net::HTTPS.new(url.host, url.port)
          request = Net::HTTPS::Post.new(url)
        end
	request["Content-Type"] = "text/csv"
        request["X_REQUEST_START"] = "t=#{Time.now.to_i}"
	request.body = report.reduce(""){|t, m| "#{t}#{m}\n"}
	begin
	  response = http.request(request)
	rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
          # do nothing
          @@next_report = current_time + REPORT_PUBLISH_RETRY_FREQ * 60
        end
	if response&.code == "200"
	  puts "Publish Success"
          @@next_report = current_time + REPORT_PUBLISH_FREQ * 60
	else
	  puts "Publish failure re-adding measurements to array"
          @@next_report = current_time + REPORT_PUBLISH_RETRY_FREQ * 60
          @@measurements.unshift(*report)
	end
      end
      puts "Measurements #{@@measurements}"
      if @@measurements.any? && @@measurements.dig(0, 0) < (current_time.to_i - MEASUREMENT_TTL * 60)
	# Remove measurements older than MEASUREMENT_TTL
        puts "Clearing old measurements"
      	@@measurements.reject!{|m| m[0] < current_time.to_i - MEASUREMENT_TTL * 60 }
      end
      puts @@measurements
      @app.call(env)
    end
  end
end
