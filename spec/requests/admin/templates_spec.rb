require 'rails_helper'

RSpec.describe 'Admin::Templates', type: :request do
  before do
    sign_in_as(create(:user, :admin))
  end

  describe 'GET /admin/templates' do
    it 'renders successfully' do
      create(:template)

      get admin_templates_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Templates')
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
              variant: 'classic',
              accent_color: '#1D4ED8',
              font_scale: 'sm'
            }
          }
        }
      end.to change(Template, :count).by(1)

      expect(response).to redirect_to(admin_template_path(Template.last))
    end
  end
end
