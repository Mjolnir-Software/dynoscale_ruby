require 'dynoscale_ruby/worker/sidekiq'

RSpec.describe DynoscaleRuby::Worker::Sidekiq do

  context ".enabled?" do
    context "when sidekiq is included in the project" do
      it "should return true" do
        expect(DynoscaleRuby::Worker::Sidekiq.enabled?).to be true
      end
    end

    context "when sidekiq is not included in the project" do
      before do
        allow(DynoscaleRuby::Worker::Sidekiq).to receive(:require).and_raise(LoadError)
      end
      it "should return false" do
        expect(DynoscaleRuby::Worker::Sidekiq.enabled?).to be false
      end
    end
  end

  context ".queue_latencies" do
    let(:queue) { double(:queue, name: "default", latency: 1, size: 10) }
    before do
      DynoscaleRuby::Worker::Sidekiq.queues([queue])
    end
    it "should return an array of queue data" do
      expect(DynoscaleRuby::Worker::Sidekiq.queue_latencies).to eq([[queue.name, (queue.latency * 1000).ceil, queue.size]])
    end
  end

  context ".queues" do
    it "should return an array" do
      expect(DynoscaleRuby::Worker::Sidekiq.queues).to be_a(Array)
    end
  end

  context ".name" do
    it "should return the worker name" do
      expect(DynoscaleRuby::Worker::Sidekiq.name).to eql('sidekiq')
    end
  end 
end
