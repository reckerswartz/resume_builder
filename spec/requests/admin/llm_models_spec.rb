require 'cgi'
require 'rails_helper'

RSpec.describe 'Admin::LlmModels', type: :request do
  before do
    sign_in_as(create(:user, :admin))
  end

  describe 'GET /admin/llm_models' do
    it 'renders the model index summary and filter shell' do
      create(:llm_model)

      get admin_llm_models_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('LLM models')
      expect(response.body).to include('Platform settings')
      expect(response.body).to include('Manage providers')
      expect(response.body).to include('Model index snapshot')
      expect(response.body).to include('Filter models')
      expect(response.body).to include('Ready for workflows')
      expect(response.body).to include('Assigned roles')
      expect(response.body).to include('Needs attention')
      expect(response.body).to include('Readiness')
      expect(response.body).to include('page-header-compact')
    end

    it 'builds summary cards from the full filtered scope, not only the current page' do
      inactive_provider = create(:llm_provider, :inactive, name: 'Archived Provider')

      10.times do |index|
        create(
          :llm_model,
          :inactive,
          llm_provider: inactive_provider,
          name: format('Alpha Model %02d', index),
          identifier: format('alpha-model-%02d', index)
        )
      end

      ready_provider = create(:llm_provider, name: 'Ready Provider')
      ready_model = create(
        :llm_model,
        llm_provider: ready_provider,
        name: 'Zulu Ready Model',
        identifier: 'zulu-ready-model',
        metadata: { 'catalog_source' => Llm::ProviderModelSyncService::CATALOG_SOURCE }
      )
      create(:llm_model_assignment, llm_model: ready_model, role: 'text_generation', position: 0)

      get admin_llm_models_path

      expect(response).to have_http_status(:ok)

      document = Nokogiri::HTML.parse(response.body)
      matches_card = document.xpath("//article[.//p[normalize-space()='Matches']]").first
      ready_card = document.xpath("//article[.//p[normalize-space()='Ready for workflows']]").first
      assigned_card = document.xpath("//article[.//p[normalize-space()='Assigned roles']]").first
      attention_card = document.xpath("//article[.//p[normalize-space()='Needs attention']]").first

      expect(matches_card.css('p')[1].text.strip).to eq('11')
      expect(matches_card.at_css('span')&.text&.strip).to eq('10 on this page')
      expect(ready_card.css('p')[1].text.strip).to eq('1')
      expect(assigned_card.css('p')[1].text.strip).to eq('1')
      expect(attention_card.css('p')[1].text.strip).to eq('10')
    end

    it 'filters and sorts models' do
      text_provider = create(:llm_provider, name: 'Text Provider')
      vision_provider = create(:llm_provider, name: 'Vision Provider')

      create(:llm_model, llm_provider: text_provider, name: 'Alpha Model', identifier: 'alpha-model', active: true, supports_vision: false)
      create(:llm_model, :inactive, :vision_capable, llm_provider: vision_provider, name: 'Vision Model', identifier: 'vision-model')
      create(:llm_model, :inactive, :vision_capable, llm_provider: vision_provider, name: 'Zeta Vision Model', identifier: 'zeta-vision-model')

      get admin_llm_models_path, params: {
        query: 'vision',
        status: 'inactive',
        capability: 'vision',
        sort: 'name',
        direction: 'desc'
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Zeta Vision Model')
      expect(response.body).to include('Vision Model')
      expect(response.body).not_to include('Alpha Model')
      expect(response.body.index('Zeta Vision Model')).to be < response.body.index('Vision Model')
    end
  end

  describe 'GET /admin/llm_models/new' do
    it 'renders the setup rail and grouped onboarding guidance' do
      get new_admin_llm_model_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Model setup')
      expect(response.body).to include('Provider readiness')
      expect(response.body).to include('Assignment coverage')
      expect(response.body).to include('Save behavior')
      expect(response.body).to include('Create model')
      expect(response.body).to include('sticky-action-bar-compact')
    end
  end

  describe 'GET /admin/llm_models/:id' do
    it 'renders the grouped model hub with readiness and assigned roles' do
      provider = create(:llm_provider, :nvidia_build)
      llm_model = create(
        :llm_model,
        :vision_capable,
        llm_provider: provider,
        name: 'Vision Review Model',
        identifier: 'vision-review-model',
        metadata: {
          'family' => 'Llama',
          'parameter_size' => '70B',
          'owned_by' => 'NVIDIA',
          'input_modalities' => [ 'text', 'image' ],
          'output_modalities' => [ 'text' ]
        }
      )
      create(:llm_model_assignment, llm_model:, role: 'text_generation', position: 0)

      get admin_llm_model_path(llm_model)
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response_body).to include('Review this model')
      expect(response_body).to include('Catalog & runtime')
      expect(response_body).to include('Operational readiness')
      expect(response_body).to include('Assigned roles')
      expect(response_body).to include('Provider readiness')
      expect(response_body).to include('Assignment order and workflow coverage')
      expect(response_body).to include('Vision Review Model')
      expect(response_body).to include('Text generation')
    end
  end

  describe 'GET /admin/llm_models/:id/edit' do
    it 'renders the grouped model setup form' do
      provider = create(:llm_provider, :nvidia_build)
      llm_model = create(:llm_model, llm_provider: provider, name: 'Draft Model', identifier: 'draft-model')

      get edit_admin_llm_model_path(llm_model)
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response_body).to include('Model identity')
      expect(response_body).to include('Runtime defaults')
      expect(response_body).to include('Activation & readiness')
      expect(response_body).to include('Model setup')
      expect(response_body).to include('Provider readiness')
      expect(response_body).to include('Assignment follow-up')
      expect(response_body).to include('Assignment coverage')
      expect(response_body).to include('Save model')
      expect(response_body).to include('Use the provider catalog identifier when possible')
      expect(response.body).to include('sticky-action-bar-compact')
    end
  end
end
