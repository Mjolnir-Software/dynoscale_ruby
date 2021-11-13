require 'dynoscale_agent/api_wrapper'
require 'dynoscale_agent/measurement'
require 'dynoscale_agent/report'

RSpec.describe DynoscaleAgent::ApiWrapper do

  context "#publish_reports" do
    let(:wrapper) { DynoscaleAgent::ApiWrapper.new("dyno.1", "https://www.example.com", "Test App") }
    let(:report) { DynoscaleAgent::Report.new(1636595665) }
    let(:reports) { [report] }

  	context "when request is successful" do
  	  it "should yield with published reports and success request state" do
  	  	expect { |b| wrapper.publish_reports(reports, Time.now, &b) }.to yield_with_args(true, reports)
      end
    end

    context "when request fails" do
      let(:http) do
        request = double("request", code: error_code)
        double("Net::HTTP", request: request, "use_ssl=": true)
      end
      context "due to a timeout" do
        let(:error_code) { 504 }
        it "should yield with empty published reports and failed request state" do
          expect { |b| wrapper.publish_reports(reports, Time.now, http, &b) }.to yield_with_args(false, [])
        end
      end
      context "due to a connection reset" do
        let(:error_code) { 503 }
        it "should yield with empty published reports and failed request state" do
          expect { |b| wrapper.publish_reports(reports, Time.now, http, &b) }.to yield_with_args(false, [])
        end
      end
      context "due to a bad request" do
        let(:error_code) { 400 }
        it "should yield with empty published reports and failed request state" do
          expect { |b| wrapper.publish_reports(reports, Time.now, http, &b) }.to yield_with_args(false, [])
        end
      end
    end
  end
end