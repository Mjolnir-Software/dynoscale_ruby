require 'dynoscale_agent/recorder'
require 'dynoscale_agent/report'

RSpec.describe DynoscaleAgent::Recorder do
  context ".record!" do
  	let(:request_queue_time) { 1 }
  	let(:request_calculator) { double(:request_calculator, request_queue_time: request_queue_time) }
    context "when there are no current reports" do
      it "should create a new report" do
      	recorder = DynoscaleAgent::Recorder.record!(request_calculator)
      	expect(recorder).to have_attributes(size: 1)
      	expect(recorder).to all(be_a(DynoscaleAgent::Report))
      end
    end

    context "when there is a current report" do
      it "should not create a new report" do
      	DynoscaleAgent::Recorder.record!(request_calculator)
        recorder = DynoscaleAgent::Recorder.record!(request_calculator)
        expect(recorder).to have_attributes(size: 1)
      	expect(recorder).to all(be_a(DynoscaleAgent::Report))
      end
    end

    context "when there is a valid queue time" do
	  it "should record the measurement" do
        recorder = DynoscaleAgent::Recorder.record!(request_calculator)
        expect(recorder.first.measurements.first.queue_time).to eq(request_queue_time)
	  end
    end
  end

  context ".reports" do
  	let(:request_queue_time) { 1 }
  	let(:request_calculator) { double(:request_calculator, request_queue_time: request_queue_time) }

  	context "when there is a report" do
      it "should return reports" do
        DynoscaleAgent::Recorder.record!(request_calculator)
        expect(DynoscaleAgent::Recorder.reports).to have_attributes(size: 1)
      	expect(DynoscaleAgent::Recorder.reports).to all(be_a(DynoscaleAgent::Report))
      end
    end
  end

  context ".remove_published_reports!" do
  	let(:request_queue_time) { 1 }
  	let(:request_calculator) { double(:request_calculator, request_queue_time: request_queue_time) }

  	context "when publish_timestamp of a report parameter matches a report publish_timestamp" do
      it "should delete the report" do
        DynoscaleAgent::Recorder.record!(request_calculator)

        reports = DynoscaleAgent::Recorder.reports
        DynoscaleAgent::Recorder.remove_published_reports!(reports)

        expect(DynoscaleAgent::Recorder.reports).to be_empty
      end
    end

    context "when publish_timestamp of a report parameter does not match a report publish_timestamp" do
      let(:report) { double("report", publish_timestamp: 1) }
      it "should not delete the report" do
        DynoscaleAgent::Recorder.record!(request_calculator)

        DynoscaleAgent::Recorder.remove_published_reports!([report])

        expect(DynoscaleAgent::Recorder.reports).to be_any
      end
    end
  end
end