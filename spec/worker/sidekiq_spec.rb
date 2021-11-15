require 'dynoscale_agent/worker/sidekiq'

RSpec.describe DynoscaleAgent::Worker::Sidekiq do

  context ".enabled?" do
    context "when sidekiq is included in the project" do
      it "should return true" do
        expect(DynoscaleAgent::Worker::Sidekiq.enabled?).to be true
      end
    end

    context "when sidekiq is not included in the project" do
      before do
        allow(DynoscaleAgent::Worker::Sidekiq).to receive(:require).and_raise(LoadError)
      end
      it "should return false" do
        expect(DynoscaleAgent::Worker::Sidekiq.enabled?).to be false
      end
    end
  end

  context ".queue_latencies" do
    let(:queue) { double(:queue, name: "default", latency: 1, size: 10) }
    before do
      DynoscaleAgent::Worker::Sidekiq.queues([queue])
    end
    it "should return an array of queue data" do
      expect(DynoscaleAgent::Worker::Sidekiq.queue_latencies).to eq([[queue.name, (queue.latency * 1000).ceil, queue.size]])
    end
  end

  context ".queues" do
    it "should return an array" do
      expect(DynoscaleAgent::Worker::Sidekiq.queues).to be_a(Array)
    end
  end

  context ".name" do
    it "should return the worker name" do
      expect(DynoscaleAgent::Worker::Sidekiq.name).to eql('sidekiq')
    end
  end 
end