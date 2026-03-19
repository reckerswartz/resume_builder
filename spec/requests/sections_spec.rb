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
    end
  end

  describe 'PATCH /resumes/:resume_id/sections/:id/move' do
    it 'reorders sections within the resume' do
      first_section = create(:section, resume:, position: 0)
      second_section = create(:section, resume:, position: 1, title: 'Projects', section_type: 'projects')

      patch move_resume_section_path(resume, second_section, direction: :up)

      expect(response).to redirect_to(edit_resume_path(resume))
      expect(second_section.reload.position).to eq(0)
      expect(first_section.reload.position).to eq(1)
    end
  end
end
