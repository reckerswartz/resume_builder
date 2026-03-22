require "rails_helper"

RSpec.describe Admin::JobLogs::RuntimeState do
  let(:job_log) { create(:job_log, active_job_id: "abc-123") }
  let(:queue_snapshot) { double("QueueSnapshot") }

  subject(:state) { described_class.new(job_log: job_log, queue_snapshot: queue_snapshot) }

  before do
    allow(queue_snapshot).to receive_messages(
      unavailable?: false,
      found?: true,
      orphaned_claimed?: false,
      state: "running",
      state_label: "Running",
      process: nil
    )
  end

  describe "#label" do
    it "returns the unavailable label when the queue is unavailable" do
      allow(queue_snapshot).to receive(:unavailable?).and_return(true)

      expect(state.label).to eq(I18n.t("admin.job_logs.helper.runtime_labels.unavailable"))
    end

    it "returns the queue snapshot state label when found" do
      expect(state.label).to eq("Running")
    end

    it "returns the missing record label when the queue record is not found" do
      allow(queue_snapshot).to receive(:found?).and_return(false)

      expect(state.label).to eq(I18n.t("admin.job_logs.helper.runtime_labels.missing_record"))
    end
  end

  describe "#tone" do
    it "returns :neutral when the queue is unavailable" do
      allow(queue_snapshot).to receive(:unavailable?).and_return(true)

      expect(state.tone).to eq(:neutral)
    end

    it "returns :warning when the job is orphaned claimed" do
      allow(queue_snapshot).to receive(:orphaned_claimed?).and_return(true)

      expect(state.tone).to eq(:warning)
    end

    it "returns the queue-state-based tone when found" do
      allow(queue_snapshot).to receive(:state).and_return("finished")

      expect(state.tone).to eq(:success)
    end

    it "returns :danger for a failed queue state" do
      allow(queue_snapshot).to receive(:state).and_return("failed")

      expect(state.tone).to eq(:danger)
    end

    it "returns :info for a queued state" do
      allow(queue_snapshot).to receive(:state).and_return("queued")

      expect(state.tone).to eq(:info)
    end

    it "returns :neutral when the queue record is not found" do
      allow(queue_snapshot).to receive(:found?).and_return(false)

      expect(state.tone).to eq(:neutral)
    end
  end

  describe "#description" do
    it "returns the unavailable description when the queue is unavailable" do
      allow(queue_snapshot).to receive(:unavailable?).and_return(true)

      expect(state.description).to eq(I18n.t("admin.job_logs.helper.runtime_descriptions.unavailable"))
    end

    it "returns the missing queue record description when not found and active_job_id is present" do
      allow(queue_snapshot).to receive(:found?).and_return(false)

      expect(state.description).to eq(I18n.t("admin.job_logs.helper.runtime_descriptions.missing_queue_record"))
    end

    it "returns the missing job reference description when not found and active_job_id is blank" do
      job_log.update!(active_job_id: nil)
      allow(queue_snapshot).to receive(:found?).and_return(false)

      expect(state.description).to eq(I18n.t("admin.job_logs.helper.runtime_descriptions.missing_job_reference"))
    end

    it "returns the worker owner description when a process is present" do
      process = double(name: "worker-1", pid: 42, present?: true)
      allow(queue_snapshot).to receive(:process).and_return(process)

      expect(state.description).to eq(I18n.t("admin.job_logs.helper.runtime_descriptions.worker_owner", worker: "worker-1 (PID 42)"))
    end

    it "returns the orphaned claimed description when orphaned" do
      allow(queue_snapshot).to receive_messages(orphaned_claimed?: true, process: nil)

      expect(state.description).to eq(I18n.t("admin.job_logs.helper.runtime_descriptions.orphaned_claimed"))
    end

    it "returns the state-specific description for known states" do
      allow(queue_snapshot).to receive(:state).and_return("scheduled")

      expect(state.description).to eq(I18n.t("admin.job_logs.helper.runtime_descriptions.scheduled"))
    end
  end

  describe "#worker_label" do
    it "returns the process name and PID when a process is present" do
      process = double(name: "web-1", pid: 99, present?: true)
      allow(queue_snapshot).to receive(:process).and_return(process)

      expect(state.worker_label).to eq("web-1 (PID 99)")
    end

    it "returns the no-worker label when orphaned claimed without a process" do
      allow(queue_snapshot).to receive_messages(orphaned_claimed?: true, process: nil)

      expect(state.worker_label).to eq(I18n.t("admin.job_logs.helper.worker.no_worker_attached"))
    end

    it "returns N/A when no process and not orphaned" do
      expect(state.worker_label).to eq("N/A")
    end
  end
end
