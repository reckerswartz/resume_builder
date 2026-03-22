require 'rails_helper'

RSpec.describe 'Home', type: :request do
  describe 'GET /' do
    it 'renders the refined landing surface for unauthenticated visitors' do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Create account')
      expect(response.body).to include('See how it works')
      expect(response.body).to include('Three simple ways to begin')
      expect(response.body).to include('Common questions')
      expect(response.body).to include('Before you start')
      expect(response.body).to include('atelier-pill')
    end

    it 'renders Start here cards as clickable links to registration' do
      get root_path

      doc = Nokogiri::HTML(response.body)
      start_here_links = doc.css('a').select { |a| a['href']&.include?(new_registration_path) }

      # Hero CTA + 3 Start here cards = at least 4 links to registration
      expect(start_here_links.size).to be >= 4

      card_titles = start_here_links.flat_map { |a| a.css('p.text-sm.font-semibold').map(&:text) }
      expect(card_titles).to include('Start from scratch')
      expect(card_titles).to include('Bring an existing resume')
      expect(card_titles).to include('Keep the preview in view')
    end

    it 'preserves locale query params through public entry links' do
      get root_path(locale: :en)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(%(href="#{new_registration_path(locale: :en)}"))
      expect(response.body).to include(%(href="#{new_session_path(locale: :en)}"))
    end

    it 'redirects authenticated users to resumes' do
      user = create(:user)
      sign_in_as(user)

      get root_path

      expect(response).to redirect_to(resumes_path)
    end
  end
end
