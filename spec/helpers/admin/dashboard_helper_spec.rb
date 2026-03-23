require 'rails_helper'

RSpec.describe Admin::DashboardHelper, type: :helper do
  describe "includes Admin::ErrorLogsHelper" do
    let(:job_error_log) do
      build(:error_log, :job, duration_ms: 1234, context: {
        "active_job_id" => "abc-123",
        "job_type" => "ResumeExportJob",
        "queue_name" => "default"
      })
    end

    let(:request_error_log) do
      build(:error_log, duration_ms: nil, context: {
        "request_id" => "req-456",
        "method" => "GET",
        "path" => "/resumes",
        "user_id" => "42"
      })
    end

    it "exposes error_log_source_badge_tone" do
      expect(helper.error_log_source_badge_tone(job_error_log)).to eq(:warning)
    end

    it "returns source label" do
      expect(helper.error_log_source_label(job_error_log)).to eq("Job")
    end

    it "returns duration label for job errors" do
      expect(helper.error_log_duration_label(job_error_log)).to eq("1.23 seconds")
    end

    it "returns N/A duration when blank" do
      expect(helper.error_log_duration_label(request_error_log)).to eq("N/A")
    end

    it "returns request summary" do
      expect(helper.error_log_request_summary(request_error_log)).to eq("GET /resumes")
    end

    it "returns primary reference label for job errors" do
      expect(helper.error_log_primary_reference_label(job_error_log)).to eq("abc-123")
    end

    it "returns primary reference label for request errors" do
      expect(helper.error_log_primary_reference_label(request_error_log)).to eq("req-456")
    end
  end
end
