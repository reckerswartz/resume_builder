require 'cgi'
require 'rails_helper'

RSpec.describe 'Admin::LlmProviders', type: :request do
  before do
    sign_in_as(create(:user, :admin))
  end

  def sync_result(success:, skipped: false, models: [], created_count: 0, updated_count: 0, deactivated_count: 0, error_message: nil)
    Llm::ProviderModelSyncService::Result.new(
      success:,
      skipped:,
      provider: nil,
      models:,
      created_count:,
      updated_count:,
      deactivated_count:,
      error_message:
    )
  end

  describe 'GET /admin/llm_providers' do
    it 'renders the provider index summary and filter shell' do
      create(:llm_provider)

      get admin_llm_providers_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('LLM providers')
      expect(response.body).to include('Platform settings')
      expect(response.body).to include('Provider index snapshot')
      expect(response.body).to include('Filter providers')
      expect(response.body).to include('Ready for requests')
      expect(response.body).to include('Needs attention')
      expect(response.body).to include('Request readiness')
      expect(response.body).to include('Catalog sync')
      expect(response.body).to include('page-header-compact')
    end

    it 'filters and sorts providers' do
      create(:llm_provider, name: 'Alpha Provider', slug: 'alpha-provider', adapter: 'ollama', active: true)
      create(:llm_provider, :nvidia_build, name: 'Vision Provider', slug: 'vision-provider', active: false)
      create(:llm_provider, :nvidia_build, name: 'Zeta Provider', slug: 'zeta-provider', active: false)

      get admin_llm_providers_path, params: {
        query: 'provider',
        status: 'inactive',
        adapter: 'nvidia_build',
        sort: 'name',
        direction: 'desc'
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Zeta Provider')
      expect(response.body).to include('Vision Provider')
      expect(response.body).not_to include('Alpha Provider')
      expect(response.body.index('Zeta Provider')).to be < response.body.index('Vision Provider')
    end
  end

  describe 'GET /admin/llm_providers/new' do
    it 'renders the setup rail and grouped onboarding guidance' do
      get new_admin_llm_provider_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Provider setup')
      expect(response.body).to include('Credential guidance')
      expect(response.body).to include('Sync behavior')
      expect(response.body).to include('Create provider')
      expect(response.body).to include('sticky-action-bar-compact')
    end
  end

  describe 'GET /admin/llm_providers/:id' do
    it 'renders the grouped provider hub and masks direct tokens in the detail screen' do
      provider = create(:llm_provider, :nvidia_build, api_key_env_var: 'nvapi-1234567890abcdef')

      get admin_llm_provider_path(provider)
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response_body).to include('Review this provider')
      expect(response_body).to include('Connection & runtime')
      expect(response_body).to include('Request readiness')
      expect(response_body).to include('Registered models')
      expect(response_body).to include('Configured for requests')
      expect(response_body).to include('Catalog and assignment follow-up')
      expect(response_body).to include('Direct token')
      expect(response_body).to include('nvapi-••••cdef')
      expect(response.body).not_to include('nvapi-1234567890abcdef')
    end
  end

  describe 'GET /admin/llm_providers/:id/edit' do
    it 'renders the grouped provider form and does not prefill direct tokens' do
      provider = create(:llm_provider, :nvidia_build, api_key_env_var: 'nvapi-1234567890abcdef')

      get edit_admin_llm_provider_path(provider)
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response_body).to include('Provider identity')
      expect(response_body).to include('Connection & credentials')
      expect(response_body).to include('Activation')
      expect(response_body).to include('Preferred security posture')
      expect(response_body).to include('Request readiness')
      expect(response_body).to include('Save provider')
      expect(response_body).to include('A direct token is already stored and masked below.')
      expect(response_body).to include('nvapi-••••cdef')
      expect(response.body).not_to include('value="nvapi-1234567890abcdef"')
      expect(response.body).to include('sticky-action-bar-compact')
    end
  end

  describe 'POST /admin/llm_providers' do
    it 'creates a provider and auto-syncs its model catalog' do
      result = sync_result(
        success: true,
        models: [ build_stubbed(:llm_model) ],
        created_count: 1,
        updated_count: 0,
        deactivated_count: 0
      )
      sync_service = instance_double(Llm::ProviderModelSyncService, call: result)
      allow(Llm::ProviderModelSyncService).to receive(:new).and_return(sync_service)

      expect do
        post admin_llm_providers_path, params: {
          llm_provider: {
            name: 'NVIDIA Build',
            slug: 'nvidia-build',
            adapter: 'nvidia_build',
            base_url: 'https://integrate.api.nvidia.com',
            api_key_env_var: 'NVIDIA_API_KEY',
            active: 'true',
            request_timeout_seconds: '45'
          }
        }
      end.to change(LlmProvider, :count).by(1)

      expect(response).to redirect_to(admin_llm_provider_path(LlmProvider.last))
      expect(flash[:notice]).to include('LLM provider created.')
      expect(flash[:notice]).to include('Synced 1 model.')
    end
  end

  describe 'POST /admin/llm_providers/:id/sync_models' do
    it 'surfaces sync errors without losing the provider record' do
      provider = create(:llm_provider, :nvidia_build)
      result = sync_result(success: false, skipped: true, error_message: 'NVIDIA Build could not resolve NVIDIA_API_KEY.')
      sync_service = instance_double(Llm::ProviderModelSyncService, call: result)
      allow(Llm::ProviderModelSyncService).to receive(:new).with(provider:).and_return(sync_service)

      post sync_models_admin_llm_provider_path(provider)

      expect(response).to redirect_to(admin_llm_provider_path(provider))
      expect(flash[:alert]).to eq('Model sync skipped: NVIDIA Build could not resolve NVIDIA_API_KEY.')
    end
  end
end
