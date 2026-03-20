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

  before do
    sign_in_as(user) if authenticated
  end

  describe 'GET /resumes' do
    it 'renders the resume workspace' do
      create(:resume, user:)

      get resumes_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Resumes')
      expect(response.body).to include('Your workspace')
      expect(response.body).to include('Open a draft, start a new resume, or compare templates without extra dashboard noise.')
      expect(response.body).to include('Quick actions')
      expect(response.body).to include('Keep moving')
      expect(response.body).to include('Create new resume')
      expect(response.body).to include('Browse templates')
      expect(response.body).to include('page-header-compact')
      expect(response.body).to include('dashboard-panel-compact')
    end

    it 'renders the empty workspace state when there are no resumes' do
      get resumes_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('No resumes yet')
      expect(response.body).to include('Create your first resume to start editing and previewing live.')
      expect(response.body).to include('Create resume')
    end
  end

  describe 'GET /resumes/new' do
    it 'renders the experience gate by default' do
      create(:template, name: 'Modern Slate')
      create(:template, name: 'Sidebar Indigo', slug: 'sidebar-indigo', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'sidebar-accent'))

      get new_resume_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Start a resume')
      expect(response.body).to include('How long have you been working?')
      expect(response.body).to include("We’ll find the best templates for your experience level.")
      expect(response.body).to include('No Experience')
      expect(response.body).to include('Less than 3 years')
      expect(response.body).to include('3-5 Years')
      expect(response.body).to include('5-10 Years')
      expect(response.body).to include('10+ Years')
      expect(response.body).not_to include('resume-create-fast-path')
      expect(response.body).not_to include('template-picker-compact')
    end

    it 'renders the setup step with only active templates after an experience selection' do
      create(:template, name: 'Modern Slate')
      create(
        :template,
        name: 'Sidebar Indigo',
        slug: 'sidebar-indigo',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'sidebar-accent')
      )
      create(:template, name: 'Legacy Hidden', active: false)

      get new_resume_path, params: {
        step: 'setup',
        resume: {
          intake_details: {
            experience_level: 'three_to_five_years'
          }
        }
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Start a resume')
      expect(response.body).to include('Experience level')
      expect(response.body).to include('3-5 Years')
      expect(response.body).to include('page-header-compact')
      expect(response.body).to include('resume-create-fast-path')
      expect(response.body).to include('Modern Slate')
      expect(response.body).to include('Sidebar Indigo')
      expect(response.body).not_to include('Legacy Hidden')
      expect(response.body).to include('Selected template')
      expect(response.body).to include('data-controller="template-picker"')
      expect(response.body).to include('template-picker-compact')
      expect(response.body).to include('Open marketplace')
      expect(response.body).to include('Browse all templates')
      expect(response.body).to include('Fast start')
      expect(response.body).to include('Add headline or summary now')
      expect(response.body).to include('Discover templates')
      expect(response.body).to include('Live sample')
      expect(response.body).to include('Family')
      expect(response.body).to include('Density')
      expect(response.body).to include('Layout')
      expect(response.body).to include('Search by name, family, or layout details')
      expect(response.body).to include('Current first')
      expect(response.body).to include('Name A–Z')
      expect(response.body).to include('Family A–Z')
      expect(response.body).to include('2 templates shown')
      expect(response.body).to include('data-template-picker-target="filterButton"')
      expect(response.body).to include('data-template-picker-target="searchInput"')
      expect(response.body).to include('data-template-picker-target="sortSelect"')
      expect(response.body).to include('data-autosave-ignore="true"')
      expect(response.body).to include('Sidebar: Skills and Education')
      expect(response.body).to include('Jordan Lee')
      expect(response.body).to include('Lead Product Engineer')
      expect(response.body).to include('No templates match those filters')
      expect(response.body).to include('dashboard-panel-compact')
    end

    it 'keeps the setup step focused on title, import, and template selection' do
      create(:template, name: 'Modern Slate')

      get new_resume_path, params: {
        step: 'setup',
        resume: {
          intake_details: {
            experience_level: 'three_to_five_years'
          }
        }
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Start a resume')
      expect(response.body).to include('Add headline or summary now')
      expect(response.body).to include('Add source text or file now')
      expect(response.body).to include('Create the draft and start editing')
      expect(response.body).to include('template-picker-compact')
      expect(response.body).to include('data-controller="source-upload"')
      expect(response.body).to include('Cloud import connectors')
      expect(response.body).to include('Google Drive')
      expect(response.body).to include('Dropbox')
      expect(response.body).to include('Coming soon')
    end

    it 'renders the student follow-up for the junior experience path' do
      create(:template, name: 'Modern Slate')

      get new_resume_path, params: {
        step: 'student',
        resume: {
          intake_details: {
            experience_level: 'less_than_3_years'
          }
        }
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Are you a student?')
      expect(response.body).to include('Yes')
      expect(response.body).to include('No')
      expect(response.body).to include('Skip for now')
      expect(response.body).not_to include('template-picker-compact')
    end

    it 'falls back to the experience gate when the student step is requested without the junior path' do
      create(:template, name: 'Modern Slate')

      get new_resume_path, params: {
        step: 'student',
        resume: {
          intake_details: {
            experience_level: 'three_to_five_years'
          }
        }
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Choose your experience level first.')
      expect(response.body).to include('How long have you been working?')
      expect(response.body).not_to include('Are you a student?')
    end

    it 'preselects a visible marketplace template when requested on the setup step' do
      default_template = create(:template, name: 'Modern Slate')
      selected_template = create(:template, name: 'Professional Blue')

      get new_resume_path, params: {
        step: 'setup',
        template_id: selected_template.id,
        resume: {
          intake_details: {
            experience_level: 'three_to_five_years'
          }
        }
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Experience level')
      expect(response.body).to include('3-5 Years')
      expect(response.body).to include('Professional Blue')
      expect(response.body).to include(%(id="resume_template_id_#{selected_template.id}"))
      expect(response.body).to include('checked="checked"')
      expect(response.body).not_to include('Template is not available.')
      expect(response.body).to include(default_template.name)
    end

    it 'surfaces intake-driven template recommendations on the setup step' do
      create(:template, name: 'ATS Minimal', slug: 'ats-minimal', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'ats-minimal'))
      create(:template, name: 'Sidebar Indigo', slug: 'sidebar-indigo', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'sidebar-accent'))
      create(:template, name: 'Modern Slate', slug: 'modern-slate', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'modern'))

      get new_resume_path, params: {
        step: 'setup',
        resume: {
          intake_details: {
            experience_level: 'less_than_3_years',
            student_status: 'student'
          }
        }
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Recommended')
      expect(response.body).to include('Best for early-career resumes')
      expect(response.body).to include('Highlights education and skills for student resumes')
      expect(response.body).to include('Recommended for this draft')
    end

    context 'when unauthenticated' do
      let(:authenticated) { false }

      it 'redirects to sign in' do
        get new_resume_path

        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'GET /resumes/:id' do
    it 'renders the preview page header and export status through shared presentation state' do
      resume = create(:resume, user:, template:, title: 'Preview Resume')

      get resume_path(resume)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Preview')
      expect(response.body).to include('Preview Resume')
      expect(response.body).to include(template.name)
      expect(response.body).to include('Back to workspace')
      expect(response.body).to include('Edit resume')
      expect(response.body).to include('Draft only')
      expect(response.body).to include('Live preview')
      expect(response.body).to include('Review before you export')
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
            template_id: template.id,
            intake_details: {
              experience_level: 'less_than_3_years',
              student_status: 'student'
            }
          }
        }
      end.to change(Resume, :count).by(1)

      expect(Resume.last.sections.count).to eq(4)
      expect(Resume.last.intake_details).to eq(
        'experience_level' => 'less_than_3_years',
        'student_status' => 'student'
      )
      expect(response).to redirect_to(edit_resume_path(Resume.last, step: 'source'))
    end

    it 'persists a blank student status when the junior path is skipped' do
      expect do
        post resumes_path, params: {
          step: 'setup',
          resume: {
            title: 'Entry Resume',
            headline: 'Junior Product Designer',
            template_id: template.id,
            intake_details: {
              experience_level: 'less_than_3_years'
            }
          }
        }
      end.to change(Resume, :count).by(1)

      expect(Resume.last.intake_details).to eq(
        'experience_level' => 'less_than_3_years',
        'student_status' => ''
      )
      expect(response).to redirect_to(edit_resume_path(Resume.last, step: 'source'))
    end

    it 'rejects a template that is no longer available' do
      create(:template, name: 'Modern Slate')
      unavailable_template = create(:template, name: 'Legacy Hidden', active: false)

      expect do
        post resumes_path, params: {
          step: 'setup',
          resume: {
            title: 'Product Resume',
            template_id: unavailable_template.id,
            intake_details: {
              experience_level: 'three_to_five_years'
            }
          }
        }
      end.not_to change(Resume, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('Template is not available')
      expect(response.body).to include('Start a resume')
      expect(response.body).to include('Experience level')
      expect(response.body).to include('3-5 Years')
      expect(response.body).to include('template-picker-compact')
    end

    it 'rerenders the setup step with import controls when create fails because the template is unavailable' do
      create(:template, name: 'Modern Slate')
      unavailable_template = create(:template, name: 'Legacy Hidden', active: false)

      Tempfile.create([ 'resume-source', '.txt' ]) do |file|
        file.write('Existing resume source')
        file.rewind

        expect do
          post resumes_path, params: {
            step: 'setup',
            resume: {
              title: 'Product Resume',
              template_id: unavailable_template.id,
              source_mode: 'upload',
              source_text: '',
              source_document: Rack::Test::UploadedFile.new(file.path, 'text/plain'),
              intake_details: {
                experience_level: 'three_to_five_years'
              }
            }
          }
        end.not_to change(Resume, :count)
      end

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('Template is not available')
      expect(response.body).to include('Start a resume')
      expect(response.body).to include('Add headline or summary now')
      expect(response.body).to include('Add source text or file now')
      expect(response.body).to include('template-picker-compact')
      expect(response.body).to include('data-controller="source-upload"')
    end
  end

  describe 'GET /resumes/:id/edit' do
    it 'renders the source setup step when requested' do
      resume = create(:resume, user:, template:)

      get edit_resume_path(resume), params: { step: 'source' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Choose how to start')
      expect(response.body).to include('Import guidance')
      expect(response.body).to include('Autofill optional')
      expect(response.body).to include('Attach a source file')
      expect(response.body).to include('Pasted resume text')
      expect(response.body).to include('No source file attached yet')
      expect(response.body).to include('Drop a file here or browse')
      expect(response.body).to include('data-controller="source-upload"')
      expect(response.body).to include('data-source-upload-target="dropzone"')
      expect(response.body).to include('Cloud import connectors')
      expect(response.body).to include('Google Drive')
      expect(response.body).to include('Dropbox')
      expect(response.body).to include('See setup')
    end

    it 'renders a supported upload review state on the source step' do
      resume = create(:resume, user:, template:, source_mode: 'upload')
      resume.source_document.attach(io: StringIO.new('%PDF-1.7'), filename: 'resume.pdf', content_type: 'application/pdf')
      create(:llm_model_assignment, llm_model:, role: 'text_generation')
      PlatformSetting.current.update!(
        feature_flags: PlatformSetting.current.feature_flags.merge(
          'llm_access' => true,
          'resume_suggestions' => true,
          'autofill_content' => true
        ),
        preferences: PlatformSetting.current.preferences
      )

      get edit_resume_path(resume), params: { step: 'source' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Ready for AI import')
      expect(response.body).to include('Autofill supported')
      expect(response.body).to include('resume.pdf')
      expect(response.body).to include('application/pdf')
      expect(response.body).to include('converted into source text during autofill')
    end

    it 'renders a reference-only upload review state on the source step for unsupported files' do
      resume = create(:resume, user:, template:, source_mode: 'upload')
      resume.source_document.attach(io: StringIO.new('legacy doc'), filename: 'resume.doc', content_type: 'application/msword')

      get edit_resume_path(resume), params: { step: 'source' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Reference file only')
      expect(response.body).to include('Reference only')
      expect(response.body).to include('resume.doc')
      expect(response.body).to include('application/msword')
      expect(response.body).to include('Keep this file attached for reference')
    end

    it 'labels the active builder step as current even when that step is already complete' do
      resume = create(:resume, user:, template:, source_mode: 'scratch')

      get edit_resume_path(resume), params: { step: 'source' }

      expect(response).to have_http_status(:ok)

      builder_steps = Nokogiri::HTML(response.body).css('nav[aria-label="Builder steps"] a')
      source_step = builder_steps.find { |node| node.text.include?('Source') }

      expect(source_step).to be_present
      expect(source_step.text).to include('Current')
    end

    it 'falls back to the heading step when an unknown step is requested' do
      resume = create(:resume, user:, template:)

      get edit_resume_path(resume), params: { step: 'unknown' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Guided builder')
      expect(response.body).to include('Heading details')
      expect(response.body).to include('Optional next step')
      expect(response.body).to include('Open personal details')
    end

    it 'renders the guided builder shell for the requested step' do
      resume = create(:resume, user:, template:)
      section = create(:section, resume:, section_type: 'experience', title: 'Experience')
      create(:entry, section:, content: { 'title' => 'Designer', 'organization' => 'Acme' })

      get edit_resume_path(resume), params: { step: 'experience' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Guided builder')
      expect(response.body).to include('Work history')
      expect(response.body).to include('Heading')
      expect(response.body).to include('Finalize')
      expect(response.body).to include('Expand to edit')
    end

    it 'renders persisted experience entries as collapsed disclosure cards with compact summaries' do
      resume = create(:resume, user:, template:)
      section = create(:section, resume:, section_type: 'experience', title: 'Experience')
      entry = create(
        :entry,
        section: section,
        content: {
          'title' => 'Engineering Manager',
          'organization' => 'Acme',
          'start_date' => '2022',
          'current_role' => true,
          'summary' => 'Led a Rails delivery team.'
        }
      )

      get edit_resume_path(resume), params: { step: 'experience' }

      expect(response).to have_http_status(:ok)

      document = Nokogiri::HTML(response.body)
      entry_card = document.at_css("##{ActionView::RecordIdentifier.dom_id(entry, :sortable_item)}")
      tips_panel = document.at_css('#experience-step-tips')

      expect(entry_card).to be_present
      expect(entry_card.name).to eq('details')
      expect(entry_card['open']).to be_nil
      expect(entry_card.text).to include('Entry canvas')
      expect(entry_card.text).to include('Engineering Manager')
      expect(entry_card.text).to include('Acme · 2022 - Present')
      expect(entry_card.text).to include('Expand to edit')
      expect(response.body).to include('Section canvas')
      expect(tips_panel).to be_present
      expect(tips_panel['open']).to be_nil
      expect(tips_panel.text).to include('Experience guidance')
    end

    it 'renders the heading step with optional personal detail affordances by default' do
      resume = create(:resume, user:, template:)

      get edit_resume_path(resume)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Heading details')
      expect(response.body).to include('Optional next step')
      expect(response.body).to include('Open personal details')
    end

    it 'renders the dedicated personal details step when requested' do
      resume = create(:resume, user:, template:)

      get edit_resume_path(resume), params: { step: 'personal_details' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Personal details')
      expect(response.body).to include('Date of Birth')
      expect(response.body).to include('Nationality')
      expect(response.body).to include('Marital Status')
      expect(response.body).to include('Visa Status')
      expect(response.body).to include('Skip for now')
      expect(response.body).to include('Save personal details')
    end

    it 'renders the summary step content when requested' do
      resume = create(:resume, user:, template:)

      get edit_resume_path(resume), params: { step: 'summary' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Professional summary')
      expect(response.body).to include('Guided summary step')
      expect(response.body).to include('Save summary')
    end

    it 'renders summary suggestions, related roles, and insert controls on the summary step' do
      resume = create(:resume, user:, template:, headline: 'Product Manager')

      get edit_resume_path(resume), params: { step: 'summary', summary_query: 'product manager' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Search by job title')
      expect(response.body).to include('Product Manager')
      expect(response.body).to include('Project Manager')
      expect(response.body).to include('Customer Success Manager')
      expect(response.body).to include('Insert this summary')
      expect(response.body).to include('data-controller="summary-suggestions"')
      expect(response.body).to include('data-controller="autosave"')
      expect(response.body).to include('data-summary-suggestions-target="input"')
      expect(response.body).to include('data-action="summary-suggestions#insert"')
    end

    it 'renders the finalize step content when requested' do
      resume = create(:resume, user:, template:)
      create(:section, resume:, section_type: 'projects', title: 'Projects')

      get edit_resume_path(resume), params: { step: 'finalize' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Finalize and export')
      expect(response.body).to include('Additional sections')
      expect(response.body).to include('Export PDF')
      expect(response.body).to include('Download TXT')
      expect(response.body).to include('Preview actions')
      expect(response.body).to include('Export stays ready')
      expect(response.body).to include('Save finalize settings')
      expect(response.body).to include('Discover templates')
      expect(response.body).to include('Live sample')
      expect(response.body).to include(%(href="#{resume_path(resume, step: 'finalize')}"))
      expect(response.body).to include('Additional sections')
      expect(response.body).to include('Section canvas')
      expect(response.body).to include('Entry canvas')
      expect(response.body).to include('data-template-picker-target="searchInput"')
      expect(response.body).to include('data-template-picker-target="sortSelect"')
      expect(response.body).to include('data-autosave-ignore="true"')
      expect(response.body).to include('Output settings')
      expect(response.body).to include('Resume link')
    end

    it 'keeps the current inactive template visible on the finalize step' do
      create(:template, name: 'Modern Slate')
      legacy_template = create(:template, name: 'Legacy Blue', active: false)
      resume = create(:resume, user:, template: legacy_template)

      get edit_resume_path(resume), params: { step: 'finalize' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Legacy Blue')
      expect(response.body).to include('Current only')
    end

    it 'renders the finalize empty state when no additional sections exist yet' do
      resume = create(:resume, user:, template:)

      get edit_resume_path(resume), params: { step: 'finalize' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('No additional sections yet')
      expect(response.body).to include('Add projects or other custom sections here once the core guided steps feel complete.')
    end

    it 'renders the shared preview shell in the edit workspace' do
      resume = create(:resume, user:, template:)

      get edit_resume_path(resume)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Guided builder')
      expect(response.body).to include('Live preview')
      expect(response.body).to include('Preview page')
      expect(response.body).to include('Open the full preview when you need more space')
      expect(response.body).to include('Live sample')
      expect(response.body).to include('Autosave on')
      expect(response.body).to include('Draft only')
    end

    it 'preserves the current builder step in preview handoff links from the edit workspace' do
      resume = create(:resume, user:, template:)

      get edit_resume_path(resume), params: { step: 'experience' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(%(href="#{resume_path(resume, step: 'experience')}"))
    end
  end

  describe 'GET /resumes/:id' do
    it 'renders the shared export summary on the preview page' do
      resume = create(:resume, user:, template:)

      get resume_path(resume)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Review the latest preview, check export status, and decide whether to download or keep editing.')
      expect(response.body).to include('Quick actions')
      expect(response.body).to include('Export or keep editing')
      expect(response.body).to include('Export PDF')
      expect(response.body).to include('Download TXT')
      expect(response.body).to include('Draft only')
      expect(response.body).to include('Preview actions')
      expect(response.body).to include('Download or go back to editing')
      expect(response.body).to include('What this shows')
    end

    it 'returns to the same builder step from the preview page when one is supplied' do
      resume = create(:resume, user:, template:)

      get resume_path(resume), params: { step: 'experience' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(%(href="#{edit_resume_path(resume, step: 'experience')}"))
    end
  end

  describe 'GET /resumes/:id/download_text' do
    it 'downloads the resume as a plain text artifact' do
      resume = create(
        :resume,
        user:,
        template:,
        title: 'Product Resume',
        headline: 'Senior Product Engineer',
        summary: 'Builds workflow systems.',
        contact_details: {
          'full_name' => 'Pat Kumar',
          'email' => 'pat@example.com',
          'phone' => '555-0100',
          'city' => 'Pune',
          'country' => 'India',
          'pin_code' => '411001',
          'website' => 'https://example.com',
          'linkedin' => 'linkedin.com/in/patkumar',
          'location' => '',
          'driving_licence' => ''
        }
      )
      section = create(:section, resume:, section_type: 'skills', title: 'Skills')
      create(:entry, section:, content: { 'name' => 'Ruby on Rails', 'level' => 'Expert' })

      get download_text_resume_path(resume)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('text/plain')
      expect(response.headers['Content-Disposition']).to include("#{resume.slug}.txt")
      expect(response.body).to include('Product Resume')
      expect(response.body).to include('Senior Product Engineer')
      expect(response.body).to include('Pat Kumar | pat@example.com | 555-0100 | Pune, India 411001')
      expect(response.body).to include('SUMMARY')
      expect(response.body).to include('Builds workflow systems.')
      expect(response.body).to include('Skills')
      expect(response.body).to include('Ruby on Rails - Expert')
    end
  end

  describe 'GET /resume_source_imports/:provider' do
    it 'redirects back with setup guidance when provider credentials are missing' do
      resume = create(:resume, user:, template:)

      get resume_source_import_path('google_drive'), params: {
        resume_id: resume.id,
        return_to: edit_resume_path(resume, step: 'source')
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Cloud import')
      expect(response.body).to include('Google Drive connector')
      expect(response.body).to include('Setup required')
      expect(response.body).to include('Google Drive import is not configured')
      expect(response.body).to include('GOOGLE_DRIVE_CLIENT_ID')
      expect(response.body).to include('Back to source step')
      expect(response.body).to include(edit_resume_path(resume, step: 'source'))
    end

    it 'renders rollout status when provider credentials are present' do
      resume = create(:resume, user:, template:)
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('DROPBOX_APP_KEY').and_return('app-key')
      allow(ENV).to receive(:[]).with('DROPBOX_APP_SECRET').and_return('app-secret')

      get resume_source_import_path('dropbox'), params: {
        resume_id: resume.id,
        return_to: edit_resume_path(resume, step: 'source')
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Dropbox connector')
      expect(response.body).to include('Configured')
      expect(response.body).to include('Dropbox import is not connected yet. Provider auth handoff is the next rollout step.')
      expect(response.body).to include('DROPBOX_APP_KEY')
      expect(response.body).to include(edit_resume_path(resume, step: 'source'))
    end

    it 'redirects invalid providers back to the source step for the current draft' do
      resume = create(:resume, user:, template:)

      get resume_source_import_path('unknown_provider'), params: {
        resume_id: resume.id,
        return_to: edit_resume_path(resume, step: 'source')
      }

      expect(response).to redirect_to(edit_resume_path(resume, step: 'source'))
      expect(flash[:alert]).to eq('Cloud import provider is not available.')
    end
  end

  describe 'PATCH /resumes/:id' do
    it 'updates source details and preserves the current source step on redirect' do
      resume = create(:resume, user:, template:)

      Tempfile.create([ 'resume-source', '.txt' ]) do |file|
        file.write('Existing resume source')
        file.rewind

        patch resume_path(resume), params: {
          step: 'source',
          resume: {
            source_mode: 'upload',
            source_text: 'Existing resume source',
            source_document: Rack::Test::UploadedFile.new(file.path, 'text/plain')
          }
        }
      end

      expect(response).to redirect_to(edit_resume_path(resume, step: 'source'))
      expect(resume.reload.source_mode).to eq('upload')
      expect(resume.source_text).to eq('Existing resume source')
      expect(resume.source_document).to be_attached
    end

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

    it 'derives full_name and location from split contact field updates' do
      resume = create(:resume, user:, template:)

      patch resume_path(resume), params: {
        resume: {
          title: 'Updated Resume',
          headline: 'Lead Builder',
          summary: 'Updated summary',
          slug: 'updated-resume',
          template_id: template.id,
          contact_details: {
            first_name: 'Pat',
            surname: 'Kumar',
            city: 'Pune',
            country: 'India',
            pin_code: '411001',
            email: 'updated@example.com'
          },
          settings: { accent_color: '#111827', show_contact_icons: 'false', page_size: 'Letter' }
        }
      }

      expect(response).to redirect_to(edit_resume_path(resume))
      expect(resume.reload.contact_details).to include(
        'full_name' => 'Pat Kumar',
        'location' => 'Pune, India 411001',
        'first_name' => 'Pat',
        'surname' => 'Kumar'
      )
    end

    it 'updates optional personal details on the dedicated step' do
      resume = create(:resume, user:, template:)

      patch resume_path(resume), params: {
        step: 'personal_details',
        resume: {
          personal_details: {
            date_of_birth: '1994-02-14',
            nationality: 'Indian',
            marital_status: 'Single',
            visa_status: 'Requires sponsorship'
          }
        }
      }

      expect(response).to redirect_to(edit_resume_path(resume, step: 'personal_details'))
      expect(resume.reload.personal_details).to include(
        'date_of_birth' => '1994-02-14',
        'nationality' => 'Indian',
        'marital_status' => 'Single',
        'visa_status' => 'Requires sponsorship'
      )
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
