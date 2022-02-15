require 'dynoscale_agent/reporter'
require 'dynoscale_agent/report'

RSpec.describe DynoscaleAgent::Reporter do
  context ".start!" do
  	let(:report) { double(:report, ready_to_publish?: true, to_csv: "1635608625,1") }
  	let(:reports) { [report] }
  	let(:recorder) { double(:recorder, reports: [report], remove_published_reports!: []) }
  	let(:api_wrapper) do
  	  dbl = double(:api_wrapper)
  	  allow(dbl).to receive(:publish_reports).and_yield(true, reports, { "publish_frequency" => 30 })
  	  dbl
  	end
    before do
      ENV['DYNOSCALE_DEV'] = "true"
    end
    context "when reports are ready for publish" do
      it "should publish reports" do
        DynoscaleAgent::Reporter.start!(recorder, api_wrapper, break_after_first_iteration: true).join
      end
    end
  end
end
