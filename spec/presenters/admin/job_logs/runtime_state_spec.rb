require "rails_helper"

RSpec.describe Admin::JobLogs::RuntimeState do
  let(:job_log) { build(:job_log, active_job_id: "job-abc-123") }

  def build_snapshot(overrides = {})
    defaults = {
      available: true,
      found?: false,
      unavailable?: false,
      state: nil,
      state_label: nil,
      orphaned_claimed?: false,
      process: nil,
      job: nil
    }
    double("QueueSnapshot", **defaults.merge(overrides))
  end

  describe "#label" do
    it "returns unavailable label when the queue adapter is not available" do
      snapshot = build_snapshot(unavailable?: true)
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.label).to eq(I18n.t("admin.job_logs.helper.runtime_labels.unavailable"))
    end

    it "returns the queue state label when the job is found" do
      snapshot = build_snapshot(found?: true, state: "running", state_label: "Running")
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.label).to eq("Running")
    end

    it "returns missing record label when the job is not found" do
      snapshot = build_snapshot(found?: false)
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.label).to eq(I18n.t("admin.job_logs.helper.runtime_labels.missing_record"))
    end
  end

  describe "#tone" do
    it "returns :neutral when the queue is unavailable" do
      snapshot = build_snapshot(unavailable?: true)
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.tone).to eq(:neutral)
    end

    it "returns :warning when the job is orphaned claimed" do
      snapshot = build_snapshot(orphaned_claimed?: true)
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.tone).to eq(:warning)
    end

    it "returns :success for a finished queue state" do
      snapshot = build_snapshot(found?: true, state: "finished")
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.tone).to eq(:success)
    end

    it "returns :danger for a failed queue state" do
      snapshot = build_snapshot(found?: true, state: "failed")
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.tone).to eq(:danger)
    end

    it "returns :warning for a running queue state" do
      snapshot = build_snapshot(found?: true, state: "running")
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.tone).to eq(:warning)
    end

    it "returns :info for a queued state" do
      snapshot = build_snapshot(found?: true, state: "queued")
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.tone).to eq(:info)
    end

    it "returns :neutral when not found and not orphaned" do
      snapshot = build_snapshot(found?: false, orphaned_claimed?: false)
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.tone).to eq(:neutral)
    end
  end

  describe "#description" do
    it "returns unavailable description when queue is unavailable" do
      snapshot = build_snapshot(unavailable?: true)
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.description).to eq(I18n.t("admin.job_logs.helper.runtime_descriptions.unavailable"))
    end

    it "returns missing queue record description when not found and job has active_job_id" do
      snapshot = build_snapshot(found?: false)
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.description).to eq(I18n.t("admin.job_logs.helper.runtime_descriptions.missing_queue_record"))
    end

    it "returns missing job reference description when not found and job has no active_job_id" do
      job_log_no_ref = build(:job_log, active_job_id: nil)
      snapshot = build_snapshot(found?: false)
      state = described_class.new(job_log: job_log_no_ref, queue_snapshot: snapshot)

      expect(state.description).to eq(I18n.t("admin.job_logs.helper.runtime_descriptions.missing_job_reference"))
    end

    it "returns worker owner description when a process is attached" do
      process = double("Process", present?: true, name: "worker-1", pid: 42)
      snapshot = build_snapshot(found?: true, state: "running", process: process)
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.description).to include("worker-1")
      expect(state.description).to include("42")
    end

    it "returns orphaned claimed description when orphaned" do
      snapshot = build_snapshot(found?: true, state: "running", orphaned_claimed?: true, process: nil)
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.description).to eq(I18n.t("admin.job_logs.helper.runtime_descriptions.orphaned_claimed"))
    end

    it "returns state-specific description for finished jobs" do
      snapshot = build_snapshot(found?: true, state: "finished", process: nil, orphaned_claimed?: false)
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.description).to eq(I18n.t("admin.job_logs.helper.runtime_descriptions.finished"))
    end
  end

  describe "#worker_label" do
    it "returns the process name and PID when a process is attached" do
      process = double("Process", present?: true, name: "worker-1", pid: 42)
      snapshot = build_snapshot(process: process)
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.worker_label).to eq("worker-1 (PID 42)")
    end

    it "returns no worker message when orphaned with no process" do
      snapshot = build_snapshot(process: nil, orphaned_claimed?: true)
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.worker_label).to eq(I18n.t("admin.job_logs.helper.worker.no_worker_attached"))
    end

    it "returns N/A when no process and not orphaned" do
      snapshot = build_snapshot(process: nil, orphaned_claimed?: false)
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.worker_label).to eq("N/A")
    end
  end
end
