require 'dynoscale_agent/report'

RSpec.describe DynoscaleAgent::Report do
  let(:report) { DynoscaleAgent::Report.new(Time.new(2021,11,11,10,51,0, "-05:00")) }
  let(:measurment_time) {  Time.new(2021,11,11,10,50,0, "-05:00") }
  let(:measurement) { double(:measurement, timestamp: measurment_time, queue_time: 1) }
  context "#add_measurement" do
  	it "should add measurement to report" do
      expect{ report.add_measurement(measurment_time, 1) }.to change(report, :measurements)
  	end
  end

  context "#add_measurements" do
  	it "should add measurement to report" do
      expect{ report.add_measurements([measurement]) }.to change(report, :measurements)
  	end
  end

  context "#ready_to_publish?" do
  	before do
      report.add_measurements([measurement])
  	end
    context "when the current time is later than the publish time" do
      let(:current_time) { Time.new(2021,11,11,10,55,0, "-05:00") }
	  it "should add measurement to report" do
	    expect(report.ready_to_publish?(current_time)).to be true
      end
    end
    context "when the current time is before than the publish time" do
      let(:current_time) { Time.new(2021,11,11,10,50,0, "-05:00") }
	  it "should add measurement to report" do
	    expect(report.ready_to_publish?(current_time)).to be false
      end
    end
  end

  context "#expired?" do
  	let(:current_time) { Time.new(2021,11,11,10,55,0, "-05:00") }
    context "when the publish_time is less than the REPORT_TTL minutes ago" do
      let(:report) { DynoscaleAgent::Report.new(current_time - DynoscaleAgent::Report::REPORT_TTL - 1) }
      it "should return true" do
        expect(report.expired?(current_time)).to be true
      end
    end
    context "when the publish_time is greater than the REPORT_TTL minutes ago" do
      let(:report) { DynoscaleAgent::Report.new(current_time - DynoscaleAgent::Report::REPORT_TTL + 1) }
      it "should return false" do
        expect(report.expired?(current_time)).to be false
      end
    end
  end

  context "#to_csv" do
  	before do
      report.add_measurements([measurement])
  	end
    it "should return serialized measurements" do
      expect(report.to_csv).to eql("#{measurement.timestamp},#{measurement.queue_time}\n")
    end
  end
  
end