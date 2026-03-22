require "rails_helper"

RSpec.describe Errors::Tracker do
  describe ".capture" do
    it "creates an ErrorLog with the error details and returns it" do
      error = StandardError.new("something broke")
      error.set_backtrace(["app/services/foo.rb:10:in `bar'", "app/controllers/baz.rb:5:in `index'"])

      error_log = described_class.capture(
        error: error,
        source: :request,
        context: { request_id: "req-123" }
      )

      expect(error_log).to be_a(ErrorLog)
      expect(error_log).to be_persisted
      expect(error_log.error_class).to eq("StandardError")
      expect(error_log.message).to eq("something broke")
      expect(error_log.source).to eq("request")
      expect(error_log.context).to include("request_id" => "req-123")
      expect(error_log.backtrace_lines).to eq(["app/services/foo.rb:10:in `bar'", "app/controllers/baz.rb:5:in `index'"])
      expect(error_log.reference_id).to start_with("ERR-")
    end

    it "truncates backtrace to 25 lines" do
      error = StandardError.new("deep stack")
      error.set_backtrace(30.times.map { |i| "frame_#{i}.rb:#{i}" })

      error_log = described_class.capture(error: error, source: :job)

      expect(error_log.backtrace_lines.size).to eq(25)
    end

    it "normalizes context as JSON with string keys" do
      error = StandardError.new("ctx test")
      error.set_backtrace([])

      error_log = described_class.capture(
        error: error,
        source: :request,
        context: { nested: { status: "ok" } }
      )

      expect(error_log.context).to eq("nested" => { "status" => "ok" })
    end

    it "records occurred_at and duration_ms when provided" do
      error = StandardError.new("timed")
      error.set_backtrace([])
      timestamp = Time.utc(2026, 3, 22, 6, 0, 0)

      error_log = described_class.capture(
        error: error,
        source: :job,
        occurred_at: timestamp,
        duration_ms: 1500
      )

      expect(error_log.occurred_at).to eq(timestamp)
      expect(error_log.duration_ms).to eq(1500)
    end

    it "logs an error message with the reference_id and context details" do
      error = StandardError.new("logged error")
      error.set_backtrace([])

      expect(Rails.logger).to receive(:error).with(a_string_matching(/ERR-.*StandardError.*logged error.*source=request/))

      described_class.capture(
        error: error,
        source: :request,
        context: { request_id: "req-abc" }
      )
    end

    it "includes request_id and active_job_id in the log message when present" do
      error = StandardError.new("ctx log")
      error.set_backtrace([])

      expect(Rails.logger).to receive(:error).with(
        a_string_matching(/request_id=req-xyz/).and(a_string_matching(/active_job_id=job-456/))
      )

      described_class.capture(
        error: error,
        source: :job,
        context: { request_id: "req-xyz", active_job_id: "job-456" }
      )
    end

    it "returns nil and logs a fallback when ErrorLog creation fails" do
      error = StandardError.new("will fail tracking")
      error.set_backtrace([])

      allow(ErrorLog).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(ErrorLog.new))

      expect(Rails.logger).to receive(:error).with(
        a_string_matching(/Error tracking failed for StandardError.*tracking error.*RecordInvalid/)
      )

      result = described_class.capture(error: error, source: :request)

      expect(result).to be_nil
    end

    it "handles nil context gracefully" do
      error = StandardError.new("nil ctx")
      error.set_backtrace([])

      error_log = described_class.capture(
        error: error,
        source: :request,
        context: nil
      )

      expect(error_log.context).to eq({})
    end
  end
end
