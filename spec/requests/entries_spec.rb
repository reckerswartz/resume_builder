require 'rails_helper'

RSpec.describe 'Entries', type: :request do
  let(:user) { create(:user) }
  let(:resume) { create(:resume, user:) }
  let(:section) { create(:section, resume:, section_type: 'experience', position: 0) }

  before do
    PlatformSetting.current.update!(feature_flags: { 'llm_access' => true, 'resume_suggestions' => true, 'autofill_content' => false }, preferences: PlatformSetting.current.preferences)
    sign_in_as(user)
  end

  describe 'POST /resumes/:resume_id/sections/:section_id/entries' do
    it 'creates an entry for the section' do
      expect do
        post resume_section_entries_path(resume, section), params: {
          entry: {
            content: {
              title: 'Senior Engineer',
              organization: 'Acme',
              highlights_text: "improved search quality\nscaled internal tooling"
            }
          }
        }
      end.to change { section.entries.count }.by(1)

      expect(response).to redirect_to(edit_resume_path(resume))
      expect(section.entries.last.highlights).to eq(['improved search quality', 'scaled internal tooling'])
    end
  end

  describe 'POST /resumes/:resume_id/sections/:section_id/entries/:id/improve' do
    it 'updates entry highlights using the suggestion service' do
      entry = create(:entry, section:, content: { 'title' => 'Engineer', 'organization' => 'Acme', 'highlights' => ['improved search quality'] })

      post improve_resume_section_entry_path(resume, section, entry)

      expect(response).to redirect_to(edit_resume_path(resume))
      expect(entry.reload.highlights.first).to start_with('Delivered')
      expect(resume.llm_interactions.last).to be_succeeded
    end
  end
end
