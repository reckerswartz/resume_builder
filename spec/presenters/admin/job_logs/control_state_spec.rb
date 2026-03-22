require "rails_helper"

RSpec.describe Admin::JobLogs::ControlState do
  let(:job_log) { create(:job_log, status: "failed") }
  let(:queue_snapshot) { double("QueueSnapshot") }

  subject(:state) { described_class.new(job_log: job_log, queue_snapshot: queue_snapshot) }

  before do
    allow(queue_snapshot).to receive_messages(
      retryable?: false,
      discardable?: false,
      orphaned_claimed?: false
    )
  end

  describe "#retry_available?" do
    it "delegates to queue_snapshot.retryable?" do
      allow(queue_snapshot).to receive(:retryable?).and_return(true)

      expect(state.retry_available?).to be true
    end

    it "returns false when the queue snapshot is not retryable" do
      expect(state.retry_available?).to be false
    end
  end

  describe "#discard_available?" do
    it "delegates to queue_snapshot.discardable?" do
      allow(queue_snapshot).to receive(:discardable?).and_return(true)

      expect(state.discard_available?).to be true
    end
  end

  describe "#requeue_available?" do
    it "returns true when the job log is failed" do
      expect(state.requeue_available?).to be true
    end

    it "returns true when the job is stale and orphaned claimed" do
      job_log.update!(status: "running", started_at: 2.hours.ago)
      allow(queue_snapshot).to receive(:orphaned_claimed?).and_return(true)

      expect(state.requeue_available?).to be true
    end

    it "returns false when the job is not failed and not orphaned" do
      job_log.update!(status: "succeeded")

      expect(state.requeue_available?).to be false
    end
  end

  describe "#requeue_label" do
    it "returns the orphaned requeue label when stale and orphaned" do
      job_log.update!(status: "running", started_at: 2.hours.ago)
      allow(queue_snapshot).to receive(:orphaned_claimed?).and_return(true)

      expect(state.requeue_label).to eq(I18n.t("admin.job_logs.helper.controls.labels.return_to_pending_queue"))
    end

    it "returns the standard requeue label otherwise" do
      expect(state.requeue_label).to eq(I18n.t("admin.job_logs.helper.controls.labels.requeue_as_new"))
    end
  end

  describe "#summary" do
    it "returns the retry+requeue+discard summary when retryable and failed" do
      allow(queue_snapshot).to receive(:retryable?).and_return(true)

      expect(state.summary).to eq(I18n.t("admin.job_logs.helper.controls.summaries.retry_requeue_discard"))
    end

    it "returns the retry-only summary when retryable but not failed" do
      job_log.update!(status: "running")
      allow(queue_snapshot).to receive(:retryable?).and_return(true)

      expect(state.summary).to eq(I18n.t("admin.job_logs.helper.controls.summaries.retry_only"))
    end

    it "returns the requeue-from-failure summary when failed but not retryable" do
      expect(state.summary).to eq(I18n.t("admin.job_logs.helper.controls.summaries.requeue_from_failure"))
    end

    it "returns the orphaned requeue summary when stale and orphaned" do
      job_log.update!(status: "running", started_at: 2.hours.ago)
      allow(queue_snapshot).to receive(:orphaned_claimed?).and_return(true)

      expect(state.summary).to eq(I18n.t("admin.job_logs.helper.controls.summaries.orphaned_requeue"))
    end

    it "returns the discardable summary when only discardable" do
      job_log.update!(status: "running")
      allow(queue_snapshot).to receive(:discardable?).and_return(true)

      expect(state.summary).to eq(I18n.t("admin.job_logs.helper.controls.summaries.discardable"))
    end

    it "returns the running-locked summary when no actions are available" do
      job_log.update!(status: "running")

      expect(state.summary).to eq(I18n.t("admin.job_logs.helper.controls.summaries.running_locked"))
    end
  end

  describe "#requeue_confirm" do
    it "returns the orphaned confirmation when stale and orphaned" do
      job_log.update!(status: "running", started_at: 2.hours.ago)
      allow(queue_snapshot).to receive(:orphaned_claimed?).and_return(true)

      expect(state.requeue_confirm).to eq(I18n.t("admin.job_logs.helper.controls.confirmations.orphaned"))
    end

    it "returns the failed requeue confirmation when failed" do
      expect(state.requeue_confirm).to eq(I18n.t("admin.job_logs.helper.controls.confirmations.requeue_failed"))
    end

    it "returns the default requeue confirmation otherwise" do
      job_log.update!(status: "running")

      expect(state.requeue_confirm).to eq(I18n.t("admin.job_logs.helper.controls.confirmations.requeue_default"))
    end
  end

  describe "#discard_confirm" do
    it "returns the discard confirmation" do
      expect(state.discard_confirm).to eq(I18n.t("admin.job_logs.helper.controls.confirmations.discard"))
    end
  end
end
