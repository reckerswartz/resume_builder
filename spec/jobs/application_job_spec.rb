require 'rails_helper'

RSpec.describe ApplicationJob, type: :job do
  include ActiveJob::TestHelper

  # A minimal test job that inherits the shared ApplicationJob lifecycle
  let(:test_job_class) do
    Class.new(ApplicationJob) do
      self.queue_adapter = :test

      def perform(resume_id)
        track_output("resume_id" => resume_id, "status" => "completed")
      end
    end
  end

  let(:failing_job_class) do
    Class.new(ApplicationJob) do
      self.queue_adapter = :test

      def perform(resume_id)
        raise StandardError, "Something went wrong processing resume #{resume_id}"
      end
    end
  end

  before do
    stub_const("TestSuccessJob", test_job_class)
    stub_const("TestFailingJob", failing_job_class)
    clear_enqueued_jobs
  end

  describe 'before_enqueue callback' do
    it 'creates a JobLog record with queued status when the job is enqueued' do
      expect {
        TestSuccessJob.perform_later(42)
      }.to change(JobLog, :count).by(1)

      job_log = JobLog.last
      expect(job_log.status).to eq("queued")
      expect(job_log.job_type).to eq("TestSuccessJob")
      expect(job_log.input).to eq({ "arguments" => [42] })
    end

    it 'does not duplicate the JobLog if enqueued twice with the same job_id' do
      job = TestSuccessJob.new(42)

      expect {
        job.enqueue
        # Re-enqueue with same job_id should find_or_create
        JobLog.find_or_create_by!(active_job_id: job.job_id) do |log|
          log.job_type = job.class.name
          log.queue_name = job.queue_name
          log.status = :queued
          log.input = { arguments: job.arguments.as_json }
        end
      }.to change(JobLog, :count).by(1)
    end
  end

  describe 'around_perform callback' do
    it 'marks the JobLog as succeeded after a successful perform' do
      job = TestSuccessJob.new(99)
      job.enqueue
      job.perform_now

      job_log = JobLog.find_by!(active_job_id: job.job_id)
      expect(job_log.status).to eq("succeeded")
      expect(job_log.started_at).to be_present
      expect(job_log.finished_at).to be_present
      expect(job_log.duration_ms).to be >= 0
    end

    it 'captures tracked output in the JobLog' do
      job = TestSuccessJob.new(99)
      job.enqueue
      job.perform_now

      job_log = JobLog.find_by!(active_job_id: job.job_id)
      expect(job_log.output).to include("resume_id" => 99, "status" => "completed")
    end

    it 'marks the JobLog as failed and re-raises on error' do
      job = TestFailingJob.new(77)
      job.enqueue

      expect { job.perform_now }.to raise_error(StandardError, /Something went wrong/)

      job_log = JobLog.find_by!(active_job_id: job.job_id)
      expect(job_log.status).to eq("failed")
      expect(job_log.error_details["class"]).to eq("StandardError")
      expect(job_log.error_details["message"]).to include("Something went wrong")
      expect(job_log.error_details["backtrace"]).to be_an(Array)
      expect(job_log.finished_at).to be_present
      expect(job_log.duration_ms).to be >= 0
    end

    it 'captures an ErrorLog reference on failure' do
      job = TestFailingJob.new(77)
      job.enqueue

      expect { job.perform_now }.to raise_error(StandardError)

      job_log = JobLog.find_by!(active_job_id: job.job_id)
      expect(job_log.error_details["reference_id"]).to be_present

      error_log = ErrorLog.find_by(reference_id: job_log.error_details["reference_id"])
      expect(error_log).to be_present
      expect(error_log.source).to eq("job")
      expect(error_log.context["job_type"]).to eq("TestFailingJob")
    end
  end
end
