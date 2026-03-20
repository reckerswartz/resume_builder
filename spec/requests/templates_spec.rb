require 'rails_helper'

RSpec.describe 'Templates', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in_as(user)
  end

  describe 'GET /templates' do
    it 'renders the signed-in template marketplace with only user-visible templates' do
      create(:template, name: 'Modern Slate')
      create(:template, name: 'Legacy Hidden', active: false)

      get templates_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Browse templates')
      expect(response.body).to include('Modern Slate')
      expect(response.body).not_to include('Legacy Hidden')
      expect(response.body).to include('Use template')
      expect(response.body).to include('data-controller="template-gallery"')
      expect(response.body).to include('Compare faster')
      expect(response.body).to include('Use search first, then open extra filters only when you need them.')
      expect(response.body).to include('Filters')
      expect(response.body).to include('Layout family')
      expect(response.body).to include('Columns')
      expect(response.body).to include('Theme')
      expect(response.body).to include('Search by name, family, or layout details')
      expect(response.body).to include('atelier-pill')
      expect(response.body).to include('data-template-gallery-target="sortSelect"')
      expect(response.body).to include('page-header-compact')
      expect(response.body).to include('data-controller="disclosure"')
    end

    it 'renders sort-aware marketplace state and orders cards by the selected sort mode' do
      create(:template, name: 'Modern Slate')
      create(:template, name: 'Classic Ivory', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic'))
      create(:template, name: 'Modern Clean Teal', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'modern-clean'))

      get templates_path, params: { sort: 'density_asc' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Sort: Density')
      expect(response.body).to include(%(value="density_asc" selected))
      expect(response.body.index('Classic Ivory')).to be < response.body.index('Modern Slate')
      expect(response.body.index('Modern Slate')).to be < response.body.index('Modern Clean Teal')
    end

    it 'surfaces intake-driven recommendations and keeps that context in template actions' do
      ats_template = create(:template, name: 'ATS Minimal', slug: 'ats-minimal', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'ats-minimal'))
      sidebar_template = create(:template, name: 'Sidebar Indigo', slug: 'sidebar-indigo', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'sidebar-accent'))
      modern_template = create(:template, name: 'Modern Slate', slug: 'modern-slate', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'modern'))

      get templates_path, params: {
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
      expect(response.body).to include(%(value="recommended_first" selected))
      expect(response.body.index('ATS Minimal')).to be < response.body.index('Sidebar Indigo')
      expect(response.body.index('Sidebar Indigo')).to be < response.body.index('Modern Slate')
      expect(response.body).to include(ERB::Util.html_escape(template_path(ats_template, resume: { intake_details: { experience_level: 'less_than_3_years', student_status: 'student' } })))
      expect(response.body).to include(ERB::Util.html_escape(new_resume_path(template_id: ats_template.id, resume: { intake_details: { experience_level: 'less_than_3_years', student_status: 'student' } })))
      expect(response.body).to include(ERB::Util.html_escape(new_resume_path(template_id: sidebar_template.id, resume: { intake_details: { experience_level: 'less_than_3_years', student_status: 'student' } })))
      expect(response.body).to include(ERB::Util.html_escape(new_resume_path(template_id: modern_template.id, resume: { intake_details: { experience_level: 'less_than_3_years', student_status: 'student' } })))
    end

    it 'filters the marketplace by query and layout metadata' do
      create(:template, name: 'Modern Slate')
      create(:template, name: 'Classic Ivory', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic'))
      create(
        :template,
        name: 'Sidebar Indigo',
        slug: 'sidebar-indigo',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'sidebar-accent')
      )

      get templates_path, params: { query: 'sidebar', family: 'sidebar-accent', column_count: 'two_column', theme_tone: 'indigo', shell_style: 'card' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Sidebar Indigo')
      expect(response.body).not_to include('Modern Slate')
      expect(response.body).not_to include('Classic Ivory')
      expect(response.body).to include('1 template shown')
      expect(response.body).to include('Sidebar Accent')
      expect(response.body).to include('2 columns')
      expect(response.body).to include('Indigo')
      expect(response.body).to include('Clear filters')
    end

    it 'renders a filter-specific empty state when nothing matches' do
      create(:template, name: 'Modern Slate')

      get templates_path, params: { query: 'nonexistent' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('No templates match the current filters')
      expect(response.body).to include('Clear filters')
    end
  end

  describe 'GET /templates/:id' do
    it 'renders the template detail page with the shared sample renderer' do
      template = create(:template, name: 'Modern Slate')
      create(:template, name: 'Classic Ivory', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic'))
      create(
        :template,
        name: 'Sidebar Indigo',
        slug: 'sidebar-indigo',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'sidebar-accent')
      )

      get template_path(template)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Template detail')
      expect(response.body).to include('Modern Slate')
      expect(response.body).to include('page-header-compact')
      expect(response.body).to include('Preview the full layout')
      expect(response.body).to include('Quick take')
      expect(response.body).to include('Live sample')
      expect(response.body).to include('Try it in the builder')
      expect(response.body).to include('Layout focus')
      expect(response.body).to include('Columns: 1 column')
      expect(response.body).to include('Theme: Slate')
      expect(response.body).to include('Jordan Lee')
      expect(response.body).to include('Lead Product Engineer')
      expect(response.body).to include(new_resume_path(template_id: template.id))
    end

    it 'preserves intake context through template detail actions' do
      template = create(:template, name: 'ATS Minimal', slug: 'ats-minimal', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'ats-minimal'))

      get template_path(template), params: {
        resume: {
          intake_details: {
            experience_level: 'less_than_3_years',
            student_status: 'student'
          }
        }
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(ERB::Util.html_escape(new_resume_path(template_id: template.id, resume: { intake_details: { experience_level: 'less_than_3_years', student_status: 'student' } })))
      expect(response.body).to include(ERB::Util.html_escape(templates_path(resume: { intake_details: { experience_level: 'less_than_3_years', student_status: 'student' } })))
    end

    it 'redirects back to the marketplace when the template is not available' do
      create(:template, name: 'Modern Slate')
      hidden_template = create(:template, name: 'Legacy Hidden', active: false)

      get template_path(hidden_template)

      expect(response).to redirect_to(templates_path)
      follow_redirect!
      expect(response.body).to include('Template is not available.')
    end
  end
end
