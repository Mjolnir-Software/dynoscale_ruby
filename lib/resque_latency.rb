module Resque

  def Job.create(queue, klass, *args)
    Resque.validate(klass, queue)

    if Resque.inline?
      new(:inline, {'class' => klass, 'args' => decode(encode(args)), 'timestamp' => Time.now.utc.to_i}).perform
    else
      Resque.push(queue, 'class' => klass.to_s, 'args' => args, 'timestamp' => Time.now.utc.to_i)
    end
  end

  def Job.new(queue, payload)
    key = ['latency', queue].join(':')

    enqueue_time = payload.is_a?(Hash) ? payload['timestamp'] : 0

    latency = Time.now.utc.to_i - enqueue_time.to_i
    redis = Resque.redis
    redis.set key, [ latency.to_s, Time.now.utc.to_i ].join(':')

    super
  end

  def latency(queue)
  	redis = Resque.redis
    l = redis.get("latency:#{queue}")

    return nil if l.nil?

    l = l.split(':').first.to_i

    return 0 if l <= 0

    l
  end

  def latency_updated_at(queue)
  	redis = Resque.redis
    l = redis.get("latency:#{queue}")

    return nil if l.nil?

    Time.at(l.split(':').last.to_i)
  end
end


