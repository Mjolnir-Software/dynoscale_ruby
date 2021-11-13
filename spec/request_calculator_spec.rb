require 'dynoscale_agent/request_calculator'

RSpec.describe DynoscaleAgent::RequestCalculator do
  context "#request_queue_time" do
  	let(:request_body_wait) { nil }
  	let(:request_start) { 1 }
  	let(:now) { Time.new(2021,11,11,10,51,0, "-05:00") }
  	let(:request_calculator) do 
  	  env = { "HTTP_X_REQUEST_START" => request_start,
  	  	      "puma.request_body_wait" => request_body_wait }
  	  DynoscaleAgent::RequestCalculator.new(env)
  	end

    context "when HTTP_X_REQUEST_START header is nil" do
      let(:request_start) { nil }

      it "should raise MissingRequestStartError" do
        expect { request_calculator.request_queue_time(now) }.to raise_error(DynoscaleAgent::MissingRequestStartError)
      end
    end

    context "when HTTP_X_REQUEST_START header is a string containing an integer timestamp" do
      let(:request_start) { "#{now.to_i * 1000 - 1}" }
      it "should convert to integer and perform calculation" do
        expect(request_calculator.request_queue_time(now)).to eq(1)
      end
    end

    context "when HTTP_X_REQUEST_START header is a string with a 't=' prefix to an integer timestamp" do
      let(:request_start) { "t=#{now.to_i * 1000 - 1}" }
      it "should convert to integer and perform calculation" do
        expect(request_calculator.request_queue_time(now)).to eq(1)
      end
    end

    context "when puma.request_body_wait is set" do
      let(:request_start) { "#{now.to_i * 1000 - 1}" }
      let(:request_body_wait) { 1 }
      it "should add to the request queue time" do
        expect(request_calculator.request_queue_time(now)).to eq(2)
      end
    end
  end
end