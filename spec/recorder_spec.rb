require 'dynoscale_ruby/recorder'
require 'dynoscale_ruby/report'

RSpec.describe DynoscaleRuby::Recorder do
  context ".record!" do
  	let(:request_queue_time) { 1 }
  	let(:request_calculator) { double(:request_calculator, request_queue_time: request_queue_time) }
    let(:workers) { [] }
    context "when there are no current reports" do
      it "should create a new report" do
      	recorder = DynoscaleRuby::Recorder.record!(request_calculator, workers)
      	expect(recorder).to have_attributes(size: 1)
      	expect(recorder).to all(be_a(DynoscaleRuby::Report))
      end
    end

    context "when there is a current report" do
      it "should not create a new report" do
      	DynoscaleRuby::Recorder.record!(request_calculator, workers)
        recorder = DynoscaleRuby::Recorder.record!(request_calculator, workers)
        expect(recorder).to have_attributes(size: 1)
      	expect(recorder).to all(be_a(DynoscaleRuby::Report))
      end
    end

    context "when there is a valid queue time" do
	  it "should record the measurement" do
        recorder = DynoscaleRuby::Recorder.record!(request_calculator, workers)
        expect(recorder.first.measurements.first.metric).to eq(request_queue_time)
	  end
    end
  end

  context ".reports" do
  	let(:request_queue_time) { 1 }
  	let(:request_calculator) { double(:request_calculator, request_queue_time: request_queue_time) }
    let(:workers) { [] }

  	context "when there is a report" do
      it "should return reports" do
        DynoscaleRuby::Recorder.record!(request_calculator, workers)
        expect(DynoscaleRuby::Recorder.reports).to have_attributes(size: 1)
      	expect(DynoscaleRuby::Recorder.reports).to all(be_a(DynoscaleRuby::Report))
      end
    end
  end

  context ".remove_published_reports!" do
  	let(:request_queue_time) { 1 }
  	let(:request_calculator) { double(:request_calculator, request_queue_time: request_queue_time) }
    let(:workers) { [] }

  	context "when publish_timestamp of a report parameter matches a report publish_timestamp" do
      it "should delete the report" do
        DynoscaleRuby::Recorder.record!(request_calculator, workers)

        reports = DynoscaleRuby::Recorder.reports
        DynoscaleRuby::Recorder.remove_published_reports!(reports)

        expect(DynoscaleRuby::Recorder.reports).to be_empty
      end
    end

    context "when publish_timestamp of a report parameter does not match a report publish_timestamp" do
      let(:report) { double("report", publish_timestamp: 1) }
      let(:workers) { [] }
      it "should not delete the report" do
        DynoscaleRuby::Recorder.record!(request_calculator, workers)

        DynoscaleRuby::Recorder.remove_published_reports!([report])

        expect(DynoscaleRuby::Recorder.reports).to be_any
      end
    end
  end
end
