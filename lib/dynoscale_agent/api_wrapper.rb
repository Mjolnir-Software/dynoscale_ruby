require 'uri'
require 'net/http'

module DynoscaleAgent
  class ApiWrapper
    def initializer(dyno, url, app_name)
      @dyno     = dyno
      @url      = URI(url)
      @app_name = app_name
    end

    def publish_reports(reports, current_time = Time.now, &block)
      headers = { "Content-Type": "text/csv",
                  "X_REQUEST_START": "t=#{current_time.to_i}",
                  "X_DYNO": @dyno,
                  "X_APP_NAME": @app_name
                }

      body = reports.reduce(""){|r| r.to_csv}

	  begin
	    response = request(headers, body)
	  rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        # ignore and let the retry mechanism handle it
      end

      success = response&.code == "200" || false
      published_reports = success ? reports : []

      yield (success, published_reports)
    end

    private

    def request(headers, body)
      if @url.scheme == "http"
        http = Net::HTTP.new(@url.host, @url.port)
        request = Net::HTTP::Post.new(@url, headers)
      else
        https = Net::HTTPS.new(@url.host, @url.port)
        request = Net::HTTPS::Post.new(@url, headers)
      end

      request.body = body
      http.request(request)
    end
  end
end