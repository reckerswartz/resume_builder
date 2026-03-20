require 'rails_helper'

RSpec.describe ResumeExportJob, type: :job do
  describe '#perform' do
    it 'attaches the exported PDF and records a succeeded job log' do
      resume = create(:resume)
      user = resume.user
      exporter = instance_double(Resumes::PdfExporter, call: '%PDF-1.4 test content')

      allow(Resumes::PdfExporter).to receive(:new).with(resume:).and_return(exporter)

      expect do
        described_class.perform_now(resume.id, user.id)
      end.to change(JobLog, :count).by(1)

      resume.reload
      job_log = JobLog.order(:created_at).last

      expect(resume.pdf_export).to be_attached
      expect(job_log).to be_succeeded
      expect(job_log.input).to eq('arguments' => [resume.id, user.id])
      expect(job_log.output).to include(
        'attachment_filename' => "#{resume.slug}.pdf",
        'requested_by_id' => user.id,
        'resume_id' => resume.id
      )
    end

    it 'records a failed job log and linked error log when export fails' do
      resume = create(:resume)
      user = resume.user
      exporter = instance_double(Resumes::PdfExporter)

      allow(Resumes::PdfExporter).to receive(:new).with(resume:).and_return(exporter)
      allow(exporter).to receive(:call).and_raise(StandardError, 'Export failed')

      expect do
        expect do
          described_class.perform_now(resume.id, user.id)
        end.to raise_error(StandardError, 'Export failed')
      end.to change(JobLog, :count).by(1).and change(ErrorLog, :count).by(1)

      job_log = JobLog.order(:created_at).last
      error_log = ErrorLog.order(:created_at).last

      expect(job_log).to be_failed
      expect(job_log.error_details).to include(
        'reference_id' => error_log.reference_id,
        'message' => 'Export failed'
      )
      expect(error_log).to be_job
      expect(error_log.context).to include(
        'active_job_id' => job_log.active_job_id,
        'job_type' => 'ResumeExportJob',
        'job_log_id' => job_log.id
      )
    end
  end
end
