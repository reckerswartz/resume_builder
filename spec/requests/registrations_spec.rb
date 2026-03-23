require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  before do
    create(:template)
  end

  describe 'GET /registration/new' do
    it 'renders the refined registration surface' do
      get new_registration_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Workspace setup')
      expect(response.body).to include('Start with a draft you can shape right away.')
      expect(response.body).to include('Starter draft included')
      expect(response.body).to include('What you get right away')
      expect(response.body).to include('Already have an account?')
      expect(response.body).to include('atelier-pill')
    end

    it 'preserves locale query params through the sign-in handoff link' do
      get new_registration_path(locale: :en)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(%(href="#{new_session_path(locale: :en)}"))
    end

    it 'shows the selected template summary when template context is present' do
      template = create(:template, name: 'ATS Minimal', slug: 'ats-minimal', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'ats-minimal'))

      get new_registration_path, params: {
        template_id: template.id,
        resume: {
          settings: { accent_color: '#334155' }
        }
      }

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      selected_template_summary = document.at_css('[data-selected-template-summary]')
      template_id_field = document.at_css("input[name='template_id']")
      accent_field = document.at_css("input[name='resume[settings][accent_color]']")

      expect(selected_template_summary).to be_present
      expect(selected_template_summary.text).to include('ATS Minimal')
      expect(template_id_field).to be_present
      expect(template_id_field['value']).to eq(template.id.to_s)
      expect(accent_field).to be_present
      expect(accent_field['value']).to eq('#334155')
    end
  end

  describe 'POST /registration' do
    it 'creates a user and starter resume' do
      expect do
        post registration_path(locale: :en), params: {
          user: {
            email_address: 'new-user@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end.to change(User, :count).by(1)

      expect(Resume.count).to eq(1)
      expect(Resume.last.sections.count).to eq(ResumeBuilder::SectionRegistry.starter_sections.size)
      expect(User.last).to be_admin
      expect(response).to redirect_to(resumes_path(locale: :en))
      expect(flash[:notice]).to eq(I18n.t('registrations.controller.workspace_ready'))
    end

    it 'creates the starter resume with the guest-selected template context' do
      default_template = Template.order(:created_at).first
      selected_template = create(:template, name: 'ATS Minimal', slug: 'ats-minimal', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'ats-minimal'))

      expect do
        post registration_path, params: {
          template_id: selected_template.id,
          resume: {
            settings: { accent_color: '#334155' }
          },
          user: {
            email_address: 'template-selected@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end.to change(User, :count).by(1)

      starter_resume = Resume.order(:created_at).last

      expect(starter_resume.template).to eq(selected_template)
      expect(starter_resume.template).not_to eq(default_template)
      expect(starter_resume.settings['accent_color']).to eq('#334155')
      expect(response).to redirect_to(resumes_path)
      expect(flash[:notice]).to eq(I18n.t('registrations.controller.workspace_ready'))
    end
  end
end
