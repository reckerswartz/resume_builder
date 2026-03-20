require 'rails_helper'
require 'zip'

RSpec.describe 'Resumes', type: :request do
  let(:template) { create(:template) }
  let(:user) { create(:user) }
  let(:llm_provider) { create(:llm_provider) }
  let(:llm_model) { create(:llm_model, llm_provider:, identifier: 'resume-autofill-request-model') }
  let(:authenticated) { true }
  let(:provider_client_class) do
    Class.new do
      def generate_text(model:, prompt:)
        {
          content: <<~JSON,
            {
              "resume": {
                "title": "Imported Resume",
                "headline": "Senior Product Engineer",
                "summary": "Builds workflow systems.",
                "contact_details": {
                  "full_name": "Pat Kumar",
                  "email": "pat@example.com",
                  "city": "Pune",
                  "country": "India"
                }
              },
              "sections": {
                "experience": [
                  {
                    "title": "Senior Product Engineer",
                    "organization": "Acme",
                    "start_date": "2022",
                    "end_date": "",
                    "current_role": true,
                    "highlights": ["Built guided builder flows"]
                  }
                ],
                "education": [],
                "skills": [
                  {
                    "name": "Ruby on Rails",
                    "level": "Advanced"
                  }
                ]
              }
            }
          JSON
          token_usage: { 'input_tokens' => 10, 'output_tokens' => 8 },
          metadata: { 'source' => 'request-spec' }
        }
      end
    end
  end

  def create_ready_photo_asset(photo_profile:, filename:, asset_kind: :enhanced, source_asset: nil)
    PhotoAsset.new(photo_profile:, source_asset:, asset_kind:, status: :ready).tap do |photo_asset|
      photo_asset.file.attach(io: StringIO.new('image-bytes'), filename:, content_type: 'image/png')
      photo_asset.save!
    end
  end

  def with_feature_flags(overrides)
    platform_setting = PlatformSetting.current
    original_feature_flags = platform_setting.feature_flags.deep_dup

    platform_setting.update!(
      feature_flags: original_feature_flags.merge(overrides.transform_keys(&:to_s)),
      preferences: platform_setting.preferences
    )

    yield
  ensure
    platform_setting.update!(feature_flags: original_feature_flags, preferences: platform_setting.preferences) if defined?(original_feature_flags)
  end

  before do
    sign_in_as(user) if authenticated
  end

  describe 'GET /resumes/:id/edit' do
    it 'preserves locale query params in builder navigation and preview handoff links' do
      resume = create(:resume, user:, template:)

      get edit_resume_path(resume, locale: :en), params: { step: 'experience' }

      expect(response).to have_http_status(:ok)
      hrefs = Nokogiri::HTML.parse(response.body).css('a[href]').map { |link| link['href'] }

      expect(hrefs).to include(resumes_path(locale: :en))
      expect(hrefs).to include(resume_path(resume, step: 'experience', locale: :en))
      expect(hrefs).to include(edit_resume_path(resume, step: 'education', locale: :en))
    end

    it 'renders the shared photo library on the personal details step when photo processing is enabled' do
      editorial_template = create(
        :template,
        name: 'Editorial Split',
        slug: 'editorial-split',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'editorial-split')
      )
      resume = create(:resume, user:, template: editorial_template)
      photo_profile = user.photo_profiles.create!(name: 'Primary Photo Library', status: :active)
      source_asset = create_ready_photo_asset(photo_profile:, filename: 'source-headshot.png', asset_kind: :source)
      selected_asset = create_ready_photo_asset(photo_profile:, source_asset:, filename: 'enhanced-headshot.png')
      photo_profile.update!(selected_source_photo_asset: source_asset)
      resume.update!(photo_profile: photo_profile)
      resume.resume_photo_selections.create!(template: resume.template, photo_asset: selected_asset, slot_name: 'headshot', status: :active)

      with_feature_flags(photo_processing: true) do
        get edit_resume_path(resume), params: { step: 'personal_details' }
      end

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('resumes.editor_personal_details_step.photo_library.title'))
      expect(response.body).to include(I18n.t('resumes.editor_personal_details_step.photo_library.selection_title'))
      expect(response.body).to include(I18n.t('resumes.editor_personal_details_step.photo_library.current_selection_title'))
      expect(response.body).to include(selected_asset.display_name)

      document = Nokogiri::HTML.parse(response.body)
      selected_radio = document.at_css("input[name='resume[selected_headshot_photo_asset_id]'][value='#{selected_asset.id}']")

      expect(selected_radio).to be_present
      expect(selected_radio['checked']).to eq('checked')
    end

    it 'returns a localized turbo alert when the selected shared headshot asset is unavailable' do
      editorial_template = create(
        :template,
        name: 'Editorial Split',
        slug: 'editorial-split',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'editorial-split')
      )
      resume = create(:resume, user:, template: editorial_template)
      missing_asset_id = PhotoAsset.maximum(:id).to_i + 1

      with_feature_flags(photo_processing: true) do
        patch resume_path(resume), params: {
          step: 'personal_details',
          resume: {
            selected_headshot_photo_asset_id: missing_asset_id
          }
        }, as: :turbo_stream
      end

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(response.body).to include(I18n.t('resumes.controller.selected_photo_unavailable'))
      expect(resume.reload.resume_photo_selections).to be_empty
    end

    it 'switches source mode and preserves uploaded documents on update' do
      resume = create(:resume, user:, template:, source_mode: 'paste', source_text: 'Existing resume source')

      Tempfile.create([ 'resume-source-upload', '.txt' ]) do |file|
        file.binmode
        file.write('Updated resume source')
        file.rewind

        patch resume_path(resume), params: {
          step: 'source',
          resume: {
            source_mode: 'upload',
            source_text: 'Updated resume source',
            source_document: Rack::Test::UploadedFile.new(file.path, 'text/plain')
          }
        }
      end

      expect(response).to redirect_to(edit_resume_path(resume, step: 'source'))
      expect(resume.reload.source_mode).to eq('upload')
      expect(resume.source_text).to eq('Updated resume source')
      expect(resume.source_document).to be_attached
    end

    it 'switches the template immediately through the finalize turbo update and refreshes the preview' do
      resume = create(:resume, user:, template: create(:template, name: 'Modern Slate'))
      sidebar_template = create(
        :template,
        name: 'Sidebar Indigo',
        slug: 'sidebar-indigo',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'sidebar-accent')
      )

      patch resume_path(resume), params: {
        step: 'finalize',
        resume: {
          template_id: sidebar_template.id
        }
      }, as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(resume.reload.template).to eq(sidebar_template)
      expect(response.body).to include(%(target="#{ActionView::RecordIdentifier.dom_id(resume, :preview)}"))
      expect(response.body).to match(/target="#{ActionView::RecordIdentifier.dom_id(resume, :preview)}".*Sidebar Indigo/m)
    end

    it 'saves source details and applies pasted-text autofill when requested' do
      resume = create(:resume, user:, template:, source_mode: 'scratch', source_text: '')
      create(:llm_model_assignment, llm_model:, role: 'text_generation')
      PlatformSetting.current.update!(
        feature_flags: {
          'llm_access' => true,
          'resume_suggestions' => true,
          'autofill_content' => true
        },
        preferences: PlatformSetting.current.preferences
      )
      allow(Llm::ClientFactory).to receive(:build).and_return(provider_client_class.new)

      patch resume_path(resume), params: {
        step: 'source',
        run_autofill: 'true',
        resume: {
          source_mode: 'paste',
          source_text: 'Pat Kumar Senior Product Engineer pat@example.com Pune India'
        }
      }

      expect(response).to redirect_to(edit_resume_path(resume, step: 'source'))
      expect(flash[:notice]).to eq(I18n.t('resumes.controller.source_applied'))
      expect(resume.reload).to have_attributes(
        title: 'Imported Resume',
        headline: 'Senior Product Engineer',
        summary: 'Builds workflow systems.',
        source_mode: 'paste'
      )
      expect(resume.contact_details).to include(
        'full_name' => 'Pat Kumar',
        'email' => 'pat@example.com',
        'city' => 'Pune',
        'country' => 'India'
      )

      experience_section = resume.sections.find_by!(section_type: 'experience')
      expect(experience_section.entries.first.content).to include(
        'title' => 'Senior Product Engineer',
        'organization' => 'Acme',
        'end_date' => 'Present'
      )
      expect(resume.sections.find_by!(section_type: 'skills').entries.first.content).to include(
        'name' => 'Ruby on Rails',
        'level' => 'Advanced'
      )

      interaction = resume.llm_interactions.last
      expect(interaction).to be_succeeded
      expect(interaction.feature_name).to eq('autofill_content')
      expect(interaction.role).to eq('text_generation')
      expect(interaction.llm_model).to eq(llm_model)
      expect(interaction.llm_provider).to eq(llm_provider)
    end

    it 'saves source details and applies upload-based autofill when requested with a supported DOCX file' do
      resume = create(:resume, user:, template:, source_mode: 'scratch', source_text: '')
      create(:llm_model_assignment, llm_model:, role: 'text_generation')
      PlatformSetting.current.update!(
        feature_flags: {
          'llm_access' => true,
          'resume_suggestions' => true,
          'autofill_content' => true
        },
        preferences: PlatformSetting.current.preferences
      )
      allow(Llm::ClientFactory).to receive(:build).and_return(provider_client_class.new)

      docx_buffer = Zip::OutputStream.write_buffer do |zip|
        zip.put_next_entry('word/document.xml')
        zip.write <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
            <w:body>
              <w:p><w:r><w:t>Pat Kumar</w:t></w:r></w:p>
              <w:p><w:r><w:t>Senior Product Engineer</w:t></w:r></w:p>
              <w:p><w:r><w:t>pat@example.com</w:t></w:r></w:p>
              <w:p><w:r><w:t>Pune India</w:t></w:r></w:p>
            </w:body>
          </w:document>
        XML
      end

      Tempfile.create([ 'resume-source-upload', '.docx' ]) do |file|
        file.binmode
        file.write(docx_buffer.string)
        file.rewind

        patch resume_path(resume), params: {
          step: 'source',
          run_autofill: 'true',
          resume: {
            source_mode: 'upload',
            source_text: '',
            source_document: Rack::Test::UploadedFile.new(file.path, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document')
          }
        }
      end

      expect(response).to redirect_to(edit_resume_path(resume, step: 'source'))
      expect(flash[:notice]).to eq(I18n.t('resumes.controller.source_applied'))
      expect(resume.reload).to have_attributes(
        title: 'Imported Resume',
        headline: 'Senior Product Engineer',
        summary: 'Builds workflow systems.',
        source_mode: 'upload'
      )
      expect(resume.source_document).to be_attached
      expect(resume.llm_interactions.last.metadata).to include(
        'source_kind' => 'uploaded_document',
        'source_content_type' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      )
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
      expect(queued_arguments).to eq([ resume.id, user.id ])

      expect(response).to redirect_to(edit_resume_path(resume))
      expect(flash[:notice]).to eq(I18n.t('resumes.controller.pdf_export_started'))
    end

    it 'returns a localized turbo notice when export is triggered from the editor' do
      resume = create(:resume, user:, template:)
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear

      expect do
        post export_resume_path(resume), as: :turbo_stream
      end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(response.body).to include(I18n.t('resumes.controller.pdf_export_started_turbo'))
    end

    it 'shows the queued export state after redirecting back to the editor' do
      resume = create(:resume, user:, template:)

      post export_resume_path(resume)
      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Queued for export')
    end
  end
end
