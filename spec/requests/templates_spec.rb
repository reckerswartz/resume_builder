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
      expect(response.body).to include('Search by name or layout details first, then narrow the gallery only when you need tighter comparison.')
      expect(response.body).to include('Search and sort')
      expect(response.body).to include('Quick choices')
      expect(response.body).to include('Full filter tray')
      expect(response.body).to include('Narrow the gallery without opening every filter')
      expect(response.body).to include('Layout family')
      expect(response.body).to include('Columns')
      expect(response.body).to include('Theme')
      expect(response.body).to include('Search by name, family, or layout details')
      expect(response.body).to include('atelier-pill')
      expect(response.body).to include('data-template-gallery-target="sortSelect"')
      expect(response.body).to include('page-header-compact')
      expect(response.body).to include('data-controller="disclosure"')
    end

    it 'preserves locale query params through marketplace actions and card links' do
      template = create(:template, name: 'Modern Slate')

      get templates_path(locale: :en)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('href="/resumes/new?locale=en"')
      expect(response.body).to include('href="/resumes?locale=en"')
      expect(response.body).to include(%(href="/templates/#{template.id}?locale=en"))
      expect(response.body).to include(%(href="/resumes/new?locale=en&amp;template_id=#{template.id}"))
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
      expect(response.body.index('Classic Ivory')).to be < response.body.index('Modern Clean Teal')
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
      expect(response.body).to include(ERB::Util.html_escape(template_path(id: ats_template, resume: { intake_details: { experience_level: 'less_than_3_years', student_status: 'student' } })))
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
      template = create(
        :template,
        name: 'Editorial Split Lime',
        slug: 'editorial-split-lime',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'editorial-split')
      )
      create(:template, name: 'Classic Ivory', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic'))
      create(
        :template,
        name: 'Sidebar Indigo',
        slug: 'sidebar-indigo',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'sidebar-accent')
      )

      get template_path(id: template)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Template detail')
      expect(response.body).to include('Editorial Split Lime')
      expect(response.body).to include('page-header-compact')
      expect(response.body).to include('Preview the full layout')
      expect(response.body).to include('Quick take')
      expect(response.body).to include('Use this template')
      expect(response.body).to include('Browse all templates')
      expect(response.body).to include('Live sample')
      expect(response.body).not_to include('Try it in the builder')
      expect(response.body).not_to include('Back to templates')
      expect(response.body).to include('Builder carry-through')
      expect(response.body).to include('Keep supporting choices secondary to the preview')
      expect(response.body).to include('Layout focus')
      expect(response.body).to include('Columns: 2 columns')
      expect(response.body).to include('Theme: Lime')
      expect(response.body).to include('Jordan Lee')
      expect(response.body).to include('Lead Product Engineer')
      expect(response.body).to include('Paper size')
      expect(response.body).to include('Letter size')
      expect(response.body).to include(new_resume_path(template_id: template.id))
    end

    it 'preserves locale query params through template detail actions' do
      template = create(:template, name: 'Modern Slate')

      get template_path(id: template, locale: :en)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(%(href="/resumes/new?locale=en&amp;template_id=#{template.id}"))
      expect(response.body).to include('href="/templates?locale=en"')
    end

    it 'preserves intake context through template detail actions' do
      template = create(:template, name: 'ATS Minimal', slug: 'ats-minimal', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'ats-minimal'))

      get template_path(id: template), params: {
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

    it 'preserves non-default accent context through template detail actions' do
      template = create(
        :template,
        name: 'Classic Ivory',
        slug: 'classic-ivory',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic')
      )

      get template_path(id: template), params: {
        resume: {
          intake_details: {
            experience_level: 'less_than_3_years',
            student_status: 'student'
          },
          settings: {
            accent_color: '#334155'
          }
        }
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Slate accent')
      expect(response.body).to include(
        ERB::Util.html_escape(
          new_resume_path(
            template_id: template.id,
            resume: {
              intake_details: { experience_level: 'less_than_3_years', student_status: 'student' },
              settings: { accent_color: '#334155' }
            }
          )
        )
      )
      expect(response.body).to include(
        ERB::Util.html_escape(
          templates_path(
            resume: {
              intake_details: { experience_level: 'less_than_3_years', student_status: 'student' },
              settings: { accent_color: '#334155' }
            }
          )
        )
      )
    end

    context 'as an unauthenticated guest' do
      before { reset!; integration_session.__send__(:default_url_options).clear }

      it 'allows guests to browse the template gallery' do
        create(:template, name: 'Modern Slate')

        get templates_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Modern Slate')
        expect(response.body).to include('Browse templates')
      end

      it 'allows guests to view template detail pages' do
        template = create(:template, name: 'Classic Ivory', layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic'))

        get template_path(id: template)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Classic Ivory')
        expect(response.body).to include('Live sample')
      end

      it 'links the Use template CTA to registration for guests' do
        template = create(:template, name: 'Modern Slate')

        get template_path(id: template)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(new_registration_path)
        expect(response.body).not_to include(new_resume_path(template_id: template.id))
      end
    end

    it 'shows Apply to resume link when the user has existing resumes' do
      template = create(:template, name: 'Modern Slate')
      resume = create(:resume, user:, template:, title: 'My Active Resume')

      get templates_path

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      apply_links = document.css('a').select { |a| a.text.include?('Apply to') }

      expect(apply_links).to be_present
      expect(apply_links.first.text).to include('My Active Resume')
      expect(apply_links.first['href']).to include(edit_resume_path(resume, step: :finalize, template_id: template.id))
    end

    it 'shows Apply to resume link on the template detail page' do
      template = create(:template, name: 'Modern Slate')
      resume = create(:resume, user:, template:, title: 'My Active Resume')

      get template_path(id: template)

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)
      apply_links = document.css('a').select { |a| a.text.include?('Apply to') }

      expect(apply_links).to be_present
      expect(apply_links.first.text).to include('My Active Resume')
      expect(apply_links.first['href']).to include(edit_resume_path(resume, step: :finalize, template_id: template.id))
    end

    it 'hides Apply to resume link for guests with no resumes' do
      reset!
      integration_session.__send__(:default_url_options).clear
      template = create(:template, name: 'Modern Slate')

      get template_path(id: template)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('Apply to')
    end

    it 'redirects back to the marketplace when the template is not available' do
      create(:template, name: 'Modern Slate')
      hidden_template = create(:template, name: 'Legacy Hidden', active: false)

      get template_path(id: hidden_template)

      expect(response).to redirect_to(templates_path)
      follow_redirect!
      expect(response.body).to include('Template is not available.')
    end
  end
end
