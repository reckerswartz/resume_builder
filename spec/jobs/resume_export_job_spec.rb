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
  end
end
