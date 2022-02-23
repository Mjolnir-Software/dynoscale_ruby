require 'singleton'

module DynoscaleRuby
  module Worker
    class Sidekiq
      include Singleton

      def self.enabled?
        require 'sidekiq/api'
        true
      rescue LoadError
        false
      end

      def self.queue_latencies
        queues.map do |queue|
          [queue.name, (queue.latency * 1000).ceil, queue.size]
      	end
      end

      def self.queues(source = ::Sidekiq::Queue.all)
        @@queues ||= source
      end

      def self.name
         'sidekiq'
      end
    end
  end
end