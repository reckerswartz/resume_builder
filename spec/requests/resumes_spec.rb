require 'rails_helper'

RSpec.describe 'Resumes', type: :request do
  let(:template) { create(:template) }
  let(:user) { create(:user) }

  before do
    sign_in_as(user)
  end

  describe 'GET /resumes' do
    it 'renders the resume workspace' do
      create(:resume, user:)

      get resumes_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Resumes')
    end
  end

  describe 'POST /resumes' do
    it 'creates a starter resume using the bootstrapper' do
      expect do
        post resumes_path, params: {
          resume: {
            title: 'Product Resume',
            headline: 'Senior Product Engineer',
            summary: 'Builds product systems',
            template_id: template.id
          }
        }
      end.to change(Resume, :count).by(1)

      expect(Resume.last.sections.count).to eq(4)
      expect(response).to redirect_to(edit_resume_path(Resume.last))
    end
  end

  describe 'PATCH /resumes/:id' do
    it 'updates resume details and nested JSON attributes' do
      resume = create(:resume, user:, template:)

      patch resume_path(resume), params: {
        resume: {
          title: 'Updated Resume',
          headline: 'Lead Builder',
          summary: 'Updated summary',
          slug: 'updated-resume',
          template_id: template.id,
          contact_details: { full_name: 'Updated User', email: 'updated@example.com' },
          settings: { accent_color: '#111827', show_contact_icons: 'false', page_size: 'Letter' }
        }
      }

      expect(response).to redirect_to(edit_resume_path(resume))
      expect(resume.reload.title).to eq('Updated Resume')
      expect(resume.contact_details).to include('full_name' => 'Updated User')
      expect(resume.settings).to include('page_size' => 'Letter', 'show_contact_icons' => false)
    end
  end

  describe 'POST /resumes/:id/export' do
    it 'enqueues a PDF export job' do
      resume = create(:resume, user:, template:)
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear

      expect do
        post export_resume_path(resume)
      end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)

      enqueued_job = ActiveJob::Base.queue_adapter.enqueued_jobs.last
      queued_arguments = enqueued_job[:args].is_a?(Hash) ? enqueued_job.dig(:args, :arguments) : enqueued_job[:args]

      expect(enqueued_job[:job]).to eq(ResumeExportJob)
      expect(queued_arguments).to eq([resume.id, user.id])

      expect(response).to redirect_to(edit_resume_path(resume))
    end
  end
end
