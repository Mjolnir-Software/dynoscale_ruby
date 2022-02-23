require 'dynoscale_ruby/worker/resque'

RSpec.describe DynoscaleRuby::Worker::Resque do

  context ".enabled?" do
    context "when resque is included in the project" do
      it "should return true" do
        expect(DynoscaleRuby::Worker::Resque.enabled?).to be true
      end
    end

    context "when resque is not included in the project" do
      before do
        allow(DynoscaleRuby::Worker::Resque).to receive(:require).and_raise(LoadError)
      end
      it "should return false" do
        expect(DynoscaleRuby::Worker::Resque.enabled?).to be false
      end
    end
  end

  context ".queue_latencies" do
    let(:queue) { double(:queue, name: "default", latency: 100, size: 10) }
    before do
      DynoscaleRuby::Worker::Resque.queues([queue])
      allow(::Resque).to receive(:size).and_return(10)
      allow(::Resque).to receive(:latency).and_return(100)
    end
    it "should return an array of queue data" do
      expect(DynoscaleRuby::Worker::Resque.queue_latencies).to eq([[queue.name, (queue.latency* 1000).ceil, queue.size]])
    end
  end

  context ".queues" do
    it "should return an array" do
      expect(DynoscaleRuby::Worker::Resque.queues).to be_a(Array)
    end
  end

  context ".name" do
    it "should return the worker name" do
      expect(DynoscaleRuby::Worker::Resque.name).to eql('resque')
    end
  end 
end