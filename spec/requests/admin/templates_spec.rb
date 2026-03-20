require 'cgi'
require 'rails_helper'

RSpec.describe 'Admin::Templates', type: :request do
  before do
    sign_in_as(create(:user, :admin))
  end

  describe 'GET /admin/templates' do
    it 'renders the template index summary and filter shell' do
      create(:template)

      get admin_templates_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Templates')
      expect(response.body).to include('Template gallery')
      expect(response.body).to include('Template index snapshot')
      expect(response.body).to include('Shared renderer')
      expect(response.body).to include('Filter templates')
      expect(response.body).to include('Filter by live visibility or cleanup targets')
      expect(response.body).to include('Layout families')
      expect(response.body).to include('page-header-compact')
    end

    it 'filters and sorts templates' do
      create(:template, name: 'Alpha Template', slug: 'alpha-template', active: true)
      create(:template, name: 'Classic Template', slug: 'classic-template', active: false)
      create(:template, name: 'Zeta Template', slug: 'zeta-template', active: false)

      get admin_templates_path, params: {
        query: 'template',
        status: 'inactive',
        sort: 'name',
        direction: 'desc'
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Zeta Template')
      expect(response.body).to include('Classic Template')
      expect(response.body).not_to include('Alpha Template')
      expect(response.body.index('Zeta Template')).to be < response.body.index('Classic Template')
    end
  end

  describe 'GET /admin/templates/:id' do
    it 'renders the grouped template hub with shared preview and config guidance' do
      template = create(:template, name: 'Modern', active: true)

      get admin_template_path(template)
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response_body).to include('Review this template')
      expect(response_body).to include('Layout profile')
      expect(response_body).to include('Shared preview')
      expect(response_body).to include('Live sample')
      expect(response_body).to include('Columns')
      expect(response_body).to include('Theme tone')
      expect(response_body).to include('Headshot metadata')
      expect(response_body).to include('Internal-only planning flag')
      expect(response_body).to include('Preview accent')
      expect(response_body).to include('Configuration')
      expect(response_body).to include('Raw layout config')
    end
  end

  describe 'GET /admin/templates/new' do
    it 'renders the grouped template setup form' do
      get new_admin_template_path
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('New template')
      expect(response_body).to include('Template identity')
      expect(response_body).to include('Layout system')
      expect(response_body).to include('Availability & preview')
      expect(response_body).to include('Preview sample')
      expect(response_body).to include('Shared preview')
      expect(response_body).to include('Theme tone')
      expect(response_body).to include('Headshot metadata')
      expect(response_body).to include('Save behavior')
      expect(response_body).to include('Accent color')
    end
  end

  describe 'GET /admin/templates/:id/edit' do
    it 'renders the grouped template edit form' do
      template = create(:template)

      get edit_admin_template_path(template)
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Edit template')
      expect(response_body).to include('Layout system')
      expect(response_body).to include('Availability & preview')
      expect(response_body).to include('Save template')
      expect(response_body).to include('Current renderer sample')
      expect(response_body).to include('Shared preview')
      expect(response_body).to include('Theme tone')
      expect(response_body).to include('Headshot metadata')
      expect(response_body).to include('Save behavior')
      expect(response.body).to include('sticky-action-bar-compact')
    end
  end

  describe 'POST /admin/templates' do
    it 'creates a template' do
      expect do
        post admin_templates_path, params: {
          template: {
            name: 'Classic',
            slug: 'classic',
            description: 'Classic layout',
            active: 'true',
            layout_config: {
              family: 'classic',
              accent_color: '#abc',
              font_scale: 'sm',
              density: 'compact',
              column_count: 'single_column',
              theme_tone: 'blue',
              supports_headshot: 'true'
            }
          }
        }
      end.to change(Template, :count).by(1)

      expect(response).to redirect_to(admin_template_path(Template.last))
      expect(Template.last.layout_config).to include(
        'family' => 'classic',
        'variant' => 'classic',
        'accent_color' => '#aabbcc',
        'font_scale' => 'sm',
        'density' => 'compact',
        'column_count' => 'single_column',
        'theme_tone' => 'blue',
        'supports_headshot' => true
      )
    end
  end
end
