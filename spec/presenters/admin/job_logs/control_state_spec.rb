require "rails_helper"

RSpec.describe Admin::JobLogs::ControlState do
  def build_snapshot(overrides = {})
    defaults = {
      retryable?: false,
      discardable?: false,
      orphaned_claimed?: false
    }
    double("QueueSnapshot", **defaults.merge(overrides))
  end

  describe "#retry_available?" do
    it "returns true when the queue snapshot is retryable" do
      snapshot = build_snapshot(retryable?: true)
      state = described_class.new(job_log: build(:job_log, :failed), queue_snapshot: snapshot)

      expect(state.retry_available?).to be true
    end

    it "returns false when the queue snapshot is not retryable" do
      snapshot = build_snapshot(retryable?: false)
      state = described_class.new(job_log: build(:job_log, :failed), queue_snapshot: snapshot)

      expect(state.retry_available?).to be false
    end
  end

  describe "#discard_available?" do
    it "returns true when the queue snapshot is discardable" do
      snapshot = build_snapshot(discardable?: true)
      state = described_class.new(job_log: build(:job_log), queue_snapshot: snapshot)

      expect(state.discard_available?).to be true
    end

    it "returns false when the queue snapshot is not discardable" do
      snapshot = build_snapshot(discardable?: false)
      state = described_class.new(job_log: build(:job_log), queue_snapshot: snapshot)

      expect(state.discard_available?).to be false
    end
  end

  describe "#requeue_available?" do
    it "returns true for a failed job log" do
      snapshot = build_snapshot
      state = described_class.new(job_log: build(:job_log, :failed), queue_snapshot: snapshot)

      expect(state.requeue_available?).to be true
    end

    it "returns true for a stale running job with an orphaned claimed snapshot" do
      job_log = build(:job_log, status: "running", started_at: 20.minutes.ago)
      snapshot = build_snapshot(orphaned_claimed?: true)
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.requeue_available?).to be true
    end

    it "returns false for a succeeded job without orphaned state" do
      snapshot = build_snapshot(orphaned_claimed?: false)
      state = described_class.new(job_log: build(:job_log, :succeeded), queue_snapshot: snapshot)

      expect(state.requeue_available?).to be false
    end
  end

  describe "#requeue_label" do
    it "returns orphaned requeue label for stale orphaned jobs" do
      job_log = build(:job_log, status: "running", started_at: 20.minutes.ago)
      snapshot = build_snapshot(orphaned_claimed?: true)
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.requeue_label).to eq(I18n.t("admin.job_logs.helper.controls.labels.return_to_pending_queue"))
    end

    it "returns standard requeue label for non-orphaned jobs" do
      snapshot = build_snapshot(orphaned_claimed?: false)
      state = described_class.new(job_log: build(:job_log, :failed), queue_snapshot: snapshot)

      expect(state.requeue_label).to eq(I18n.t("admin.job_logs.helper.controls.labels.requeue_as_new"))
    end
  end

  describe "#summary" do
    it "returns retry+requeue+discard summary when retryable and failed" do
      snapshot = build_snapshot(retryable?: true)
      state = described_class.new(job_log: build(:job_log, :failed), queue_snapshot: snapshot)

      expect(state.summary).to eq(I18n.t("admin.job_logs.helper.controls.summaries.retry_requeue_discard"))
    end

    it "returns retry-only summary when retryable but not failed" do
      snapshot = build_snapshot(retryable?: true)
      state = described_class.new(job_log: build(:job_log, :succeeded), queue_snapshot: snapshot)

      expect(state.summary).to eq(I18n.t("admin.job_logs.helper.controls.summaries.retry_only"))
    end

    it "returns requeue-from-failure summary for failed non-retryable jobs" do
      snapshot = build_snapshot(retryable?: false)
      state = described_class.new(job_log: build(:job_log, :failed), queue_snapshot: snapshot)

      expect(state.summary).to eq(I18n.t("admin.job_logs.helper.controls.summaries.requeue_from_failure"))
    end

    it "returns running-locked summary when no actions are available" do
      snapshot = build_snapshot(retryable?: false, discardable?: false, orphaned_claimed?: false)
      state = described_class.new(job_log: build(:job_log, :succeeded), queue_snapshot: snapshot)

      expect(state.summary).to eq(I18n.t("admin.job_logs.helper.controls.summaries.running_locked"))
    end

    it "returns discardable summary when only discard is available" do
      snapshot = build_snapshot(discardable?: true)
      state = described_class.new(job_log: build(:job_log, :succeeded), queue_snapshot: snapshot)

      expect(state.summary).to eq(I18n.t("admin.job_logs.helper.controls.summaries.discardable"))
    end
  end

  describe "#requeue_confirm" do
    it "returns orphaned confirmation for stale orphaned jobs" do
      job_log = build(:job_log, status: "running", started_at: 20.minutes.ago)
      snapshot = build_snapshot(orphaned_claimed?: true)
      state = described_class.new(job_log: job_log, queue_snapshot: snapshot)

      expect(state.requeue_confirm).to eq(I18n.t("admin.job_logs.helper.controls.confirmations.orphaned"))
    end

    it "returns failed requeue confirmation for failed jobs" do
      snapshot = build_snapshot(orphaned_claimed?: false)
      state = described_class.new(job_log: build(:job_log, :failed), queue_snapshot: snapshot)

      expect(state.requeue_confirm).to eq(I18n.t("admin.job_logs.helper.controls.confirmations.requeue_failed"))
    end

    it "returns default confirmation otherwise" do
      snapshot = build_snapshot(orphaned_claimed?: false)
      state = described_class.new(job_log: build(:job_log, :succeeded), queue_snapshot: snapshot)

      expect(state.requeue_confirm).to eq(I18n.t("admin.job_logs.helper.controls.confirmations.requeue_default"))
    end
  end

  describe "#discard_confirm" do
    it "returns the localized discard confirmation" do
      snapshot = build_snapshot
      state = described_class.new(job_log: build(:job_log), queue_snapshot: snapshot)

      expect(state.discard_confirm).to eq(I18n.t("admin.job_logs.helper.controls.confirmations.discard"))
    end
  end
end
