module DynoscaleAgent
  class RequestCalculator

    def initialize(env)
      @env = env
    end

    def request_queue_time(time_now = Time.now)
      is_dev = ENV['DYNOSCALE_DEV'] == 'true'

      if is_dev
        request_start = "#{Time.now - (rand*100).ceil}"
      else
        request_start = @env['HTTP_X_REQUEST_START']
      end
      raise MissingRequestStartError if request_start.nil?
      
      request_body_wait = @env['puma.request_body_wait'] || 0

      request_start_string = request_start.match(/([0-9])+/)&.[](0)
      start_at = Time.at(request_start_string.to_i / 1000)

      (time_now - start_at).to_i + request_body_wait.to_i
    end
  end
  class MissingRequestStartError < StandardError
  end
end
