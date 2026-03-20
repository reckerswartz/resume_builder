require 'rails_helper'

RSpec.describe 'Sections', type: :request do
  let(:user) { create(:user) }
  let(:resume) { create(:resume, user:) }

  before do
    sign_in_as(user)
  end

  describe 'POST /resumes/:resume_id/sections' do
    it 'creates a section for the current users resume' do
      expect do
        post resume_sections_path(resume), params: {
          section: {
            title: 'Projects',
            section_type: 'projects'
          }
        }
      end.to change { resume.sections.count }.by(1)

      expect(response).to redirect_to(edit_resume_path(resume))
      expect(flash[:notice]).to eq(I18n.t('resumes.sections_controller.created'))
    end

    it 'preserves locale query params on successful create redirects' do
      post resume_sections_path(resume, locale: :en), params: {
        section: {
          title: 'Projects',
          section_type: 'projects'
        }
      }

      expect(response).to redirect_to(edit_resume_path(resume, locale: :en))
      expect(flash[:notice]).to eq(I18n.t('resumes.sections_controller.created'))
    end
  end

  describe 'PATCH /resumes/:resume_id/sections/:id/move' do
    it 'reorders sections within the resume' do
      first_section = create(:section, resume:, position: 0)
      second_section = create(:section, resume:, position: 1, title: 'Projects', section_type: 'projects')

      patch move_resume_section_path(resume, second_section, direction: :up)

      expect(response).to redirect_to(edit_resume_path(resume))
      expect(flash[:notice]).to eq(I18n.t('resumes.sections_controller.moved'))
      expect(second_section.reload.position).to eq(0)
      expect(first_section.reload.position).to eq(1)
    end

    it 'returns targeted Turbo Stream updates for drag-and-drop reordering' do
      first_section = create(:section, resume:, position: 0)
      second_section = create(:section, resume:, position: 1, title: 'Projects', section_type: 'projects')

      patch move_resume_section_path(resume, second_section), params: { position: 0, step: 'finalize' }, as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(second_section.reload.position).to eq(0)
      expect(first_section.reload.position).to eq(1)
      expect(response.body).to include(%(target="#{ActionView::RecordIdentifier.dom_id(resume, :workspace_overview)}"))
      expect(response.body).to include(%(target="#{ActionView::RecordIdentifier.dom_id(resume, :editor_step_content)}"))
      expect(response.body).to include(I18n.t('resumes.sections_controller.moved'))
    end
  end
end
