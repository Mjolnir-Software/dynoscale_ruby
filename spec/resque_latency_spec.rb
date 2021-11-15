require 'resque'
require 'resque_latency'

RSpec.describe Resque do
  let(:queue) { "default" }

  context "Job.create" do
    context "when called inline" do
      before do 
      	allow(::Resque).to receive(:inline?).and_return(true)
      end
      it "should return true" do
        expect(Resque::Job.create(queue, TestJob)).to be true
      end
    end

    context "when not called inline" do
      it "should return array" do
        expect(Resque::Job.create(queue, TestJob)).to be_a(Array)
      end
    end
  end

  context "Job.new" do
    it "should record the latency" do
      expect{ Resque::Job.new(queue, []) }.to change{Resque.redis.get("latency:#{queue}")}
    end
  end

  context ".latency" do
    let(:latency) { 10 }
    let(:now) { Time.new(2021,11,11,10,51,0, "-05:00") }
    before do
      Resque.redis.set("latency:#{queue}", "#{latency}:#{now}")
    end
    it "should return the queue latency" do
      expect(Resque.latency(queue)).to eql(latency)
    end
  end

  context ".latency_updated_at" do
    let(:latency) { 10 }
    let(:now) { Time.new(2021,11,11,10,51,0, "-05:00") }
    before do
      Resque.redis.set("latency:#{queue}", "#{latency}:#{now.to_i}")
    end
    it "should return the queue latency update date" do
      expect(Resque.latency_updated_at(queue)).to eql(now)
    end
  end
  
end

class TestJob
  def self.perform
    "This is a test job"
  end
end