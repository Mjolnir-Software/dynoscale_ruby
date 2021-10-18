module DynoscaleAgent
  class RequestCalculator
    def initialize(env)
      @env = env
    end

    def request_queue_time
      request_start     = @env['HTTP_X_REQUEST_START']
      raise MissingRequestStartError, "The X_REQUEST_START header is missing from the request" if request_start.nil?
      request_body_wait = @env['puma.request_body_wait'] || 0

      request_start_string = request_start.match(/([0-9])+/).try(:[], 0)
      start_at = Time.at(request_start_string.to_i / 1000)
      puts "HTTP_X_REQUEST_START: #{@env['HTTP_X_REQUEST_START']} r@env['puma.request_body_wait']: #{@env['puma.request_body_wait']} request_start_string: #{request_start_string}"
      (Time.now - start_at).to_i - request_body_wait.to_i
    end
  end
  class MissingRequestStartError < StandardError
  end
end
