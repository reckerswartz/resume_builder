require 'rails_helper'

RSpec.describe 'Entries', type: :request do
  let(:user) { create(:user) }
  let(:resume) { create(:resume, user:) }
  let(:section) { create(:section, resume:, section_type: 'experience', position: 0) }
  let(:llm_provider) { create(:llm_provider) }
  let(:llm_model) { create(:llm_model, llm_provider:, identifier: 'request-model') }
  let!(:llm_model_assignment) { create(:llm_model_assignment, llm_model:, role: 'text_generation') }
  let(:provider_client_class) do
    Class.new do
      def generate_text(model:, prompt:)
        {
          content: '{"highlights":["Delivered improved search quality"]}',
          token_usage: { 'input_tokens' => 8, 'output_tokens' => 5 },
          metadata: { 'source' => 'request-spec' }
        }
      end
    end
  end
 
  before do
    PlatformSetting.current.update!(feature_flags: { 'llm_access' => true, 'resume_suggestions' => true, 'autofill_content' => false }, preferences: PlatformSetting.current.preferences)
    sign_in_as(user)
    allow(Llm::ClientFactory).to receive(:build).and_return(provider_client_class.new)
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
      expect(flash[:notice]).to eq(I18n.t('resumes.entries_controller.created'))
      expect(section.entries.last.highlights).to eq(['improved search quality', 'scaled internal tooling'])
    end

    it 'preserves locale query params on successful create redirects' do
      post resume_section_entries_path(resume, section, locale: :en), params: {
        entry: {
          content: {
            title: 'Senior Engineer',
            organization: 'Acme'
          }
        }
      }

      expect(response).to redirect_to(edit_resume_path(resume, locale: :en))
      expect(flash[:notice]).to eq(I18n.t('resumes.entries_controller.created'))
    end

    it 'normalizes guided experience fields into the preview-friendly JSON shape' do
      post resume_section_entries_path(resume, section), params: {
        entry: {
          content: {
            title: 'Senior Engineer',
            organization: 'Acme',
            remote: 'true',
            start_month: 'May',
            start_year: '2022',
            end_month: 'June',
            end_year: '2024',
            current_role: 'false'
          }
        }
      }

      expect(section.entries.last.content).to include(
        'remote' => true,
        'current_role' => false,
        'start_date' => 'May 2022',
        'end_date' => 'June 2024'
      )
    end
  end

  describe 'POST /resumes/:resume_id/sections/:section_id/entries/:id/improve' do
    it 'updates entry highlights using the suggestion service' do
      entry = create(:entry, section:, content: { 'title' => 'Engineer', 'organization' => 'Acme', 'highlights' => ['improved search quality'] })

      post improve_resume_section_entry_path(resume, section, entry)

      expect(response).to redirect_to(edit_resume_path(resume))
      expect(flash[:notice]).to eq(I18n.t('resumes.entries_controller.improved'))
      expect(entry.reload.highlights).to eq(['Delivered improved search quality'])

      interaction = resume.reload.llm_interactions.last
      expect(interaction).to be_succeeded
      expect(interaction.llm_model).to eq(llm_model)
      expect(interaction.llm_provider).to eq(llm_provider)
      expect(interaction.role).to eq('text_generation')
      expect(entry.reload.highlights.first).to start_with('Delivered')
      expect(resume.llm_interactions.last).to be_succeeded
    end

    it 'uses the localized fallback alert when suggestions are unavailable' do
      entry = create(:entry, section:, content: { 'title' => 'Engineer', 'organization' => 'Acme' })
      failed_result = Llm::ResumeSuggestionService::Result.new(
        success: false,
        content: entry.content,
        interactions: [],
        error_message: nil
      )

      allow(Llm::ResumeSuggestionService).to receive(:new).with(user: user, entry: entry).and_return(instance_double(Llm::ResumeSuggestionService, call: failed_result))

      post improve_resume_section_entry_path(resume, section, entry, locale: :en)

      expect(response).to redirect_to(edit_resume_path(resume, locale: :en))
      expect(flash[:alert]).to eq(I18n.t('resumes.entries_controller.improve_unavailable'))
    end
  end

  describe 'PATCH /resumes/:resume_id/sections/:section_id/entries/:id/move' do
    it 'returns targeted Turbo Stream updates for drag-and-drop reordering' do
      first_entry = create(:entry, section:, position: 0, content: { 'title' => 'First', 'organization' => 'Acme' })
      second_entry = create(:entry, section:, position: 1, content: { 'title' => 'Second', 'organization' => 'Acme' })

      patch move_resume_section_entry_path(resume, section, second_entry), params: { position: 0, step: 'experience' }, as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(second_entry.reload.position).to eq(0)
      expect(first_entry.reload.position).to eq(1)
      expect(response.body).to include(%(target="#{ActionView::RecordIdentifier.dom_id(resume, :editor_step_content)}"))
      expect(response.body).to include(%(target="#{ActionView::RecordIdentifier.dom_id(resume, :preview)}"))
      expect(response.body).to include(I18n.t('resumes.entries_controller.moved'))
    end
  end
end
