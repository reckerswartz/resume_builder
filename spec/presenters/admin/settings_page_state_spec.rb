require 'rails_helper'

RSpec.describe Admin::SettingsPageState do
  let(:platform_setting) do
    create(
      :platform_setting,
      feature_flags: {
        'llm_access' => true,
        'resume_suggestions' => true,
        'autofill_content' => false
      },
      preferences: {
        'default_template_slug' => 'classic',
        'support_email' => 'support@resume.test'
      }
    )
  end
  let(:text_model) { create(:llm_model, identifier: 'text-primary') }
  let(:text_verifier) { create(:llm_model, identifier: 'text-verifier') }
  let(:vision_model) { create(:llm_model, :vision_capable, identifier: 'vision-primary') }
  let(:vision_verifier) { create(:llm_model, :vision_capable, identifier: 'vision-verifier') }
  let(:llm_models) { [ text_model, text_verifier, vision_model, vision_verifier ] }
  let(:text_llm_models) { [ text_model, text_verifier ] }
  let(:vision_llm_models) { [ vision_model, vision_verifier ] }
  let(:llm_assignment_model_ids) do
    {
      'text_generation' => [ text_model.id ],
      'text_verification' => [ text_model.id, text_verifier.id ],
      'vision_generation' => [ vision_model.id ],
      'vision_verification' => [ vision_verifier.id ]
    }
  end
  let(:llm_providers_count) { 2 }
  let(:feature_flags) do
    [
      { key: 'llm_access', enabled: true },
      { key: 'resume_suggestions', enabled: true },
      { key: 'autofill_content', enabled: false }
    ]
  end
  let(:cloud_import_provider_states) do
    [
      { key: 'google_drive', configured: true },
      { key: 'dropbox', configured: false }
    ]
  end
  let(:view_context) { instance_double('view_context') }

  subject(:page_state) do
    described_class.new(
      platform_setting: platform_setting,
      llm_models: llm_models,
      text_llm_models: text_llm_models,
      vision_llm_models: vision_llm_models,
      llm_assignment_model_ids: llm_assignment_model_ids,
      llm_providers_count: llm_providers_count,
      view_context: view_context
    )
  end

  before do
    allow(view_context).to receive(:feature_flags_for_settings).with(platform_setting).and_return(feature_flags)
    allow(view_context).to receive(:cloud_import_provider_states_for_settings).and_return(cloud_import_provider_states)
    allow(view_context).to receive(:admin_templates_path).and_return('/admin/templates')
    allow(view_context).to receive(:admin_llm_providers_path).and_return('/admin/llm_providers')
    allow(view_context).to receive(:admin_llm_models_path).and_return('/admin/llm_models')
  end

  describe '#page_header_attributes' do
    it 'builds the shared admin settings header payload from the extracted state' do
      expect(page_state.page_header_attributes).to eq(
        eyebrow: I18n.t('admin.settings_page_state.page_header.eyebrow'),
        title: I18n.t('admin.settings_page_state.page_header.title'),
        description: I18n.t('admin.settings_page_state.page_header.description'),
        badges: [
          { label: I18n.t('admin.settings_page_state.page_header.badges.enabled', enabled: 2, total: 3), tone: :neutral },
          { label: I18n.t('admin.settings_page_state.page_header.badges.providers', count: 2), tone: :neutral },
          { label: I18n.t('admin.settings_page_state.page_header.badges.models', count: 4), tone: :neutral }
        ],
        actions: [
          { label: I18n.t('admin.settings_page_state.page_header.actions.manage_templates'), path: '/admin/templates', style: :secondary },
          { label: I18n.t('admin.settings_page_state.page_header.actions.manage_providers'), path: '/admin/llm_providers', style: :secondary },
          { label: I18n.t('admin.settings_page_state.page_header.actions.manage_models'), path: '/admin/llm_models', style: :primary }
        ],
        density: :compact
      )
    end
  end

  describe '#hub_sections' do
    it 'builds localized labels and captions for the settings navigation rail' do
      expect(page_state.hub_sections).to eq([
        {
          id: 'feature-access',
          label: I18n.t('admin.settings_page_state.hub_sections.feature_access.label'),
          caption: I18n.t('admin.settings_page_state.hub_sections.feature_access.caption')
        },
        {
          id: 'platform-defaults',
          label: I18n.t('admin.settings_page_state.hub_sections.platform_defaults.label'),
          caption: I18n.t('admin.settings_page_state.hub_sections.platform_defaults.caption')
        },
        {
          id: 'cloud-import-connectors',
          label: I18n.t('admin.settings_page_state.hub_sections.cloud_import_connectors.label'),
          caption: I18n.t('admin.settings_page_state.hub_sections.cloud_import_connectors.caption')
        },
        {
          id: 'llm-orchestration',
          label: I18n.t('admin.settings_page_state.hub_sections.llm_orchestration.label'),
          caption: I18n.t('admin.settings_page_state.hub_sections.llm_orchestration.caption')
        }
      ])
    end
  end

  describe 'workflow model selections' do
    it 'resolves the primary and verification model state for each workflow' do
      expect(page_state.text_primary_model).to eq(text_model)
      expect(page_state.text_generation_model_id).to eq(text_model.id)
      expect(page_state.text_verification_models).to eq([ text_model, text_verifier ])
      expect(page_state.text_verification_model_ids).to eq([ text_model.id, text_verifier.id ])
      expect(page_state.vision_primary_model).to eq(vision_model)
      expect(page_state.vision_generation_model_id).to eq(vision_model.id)
      expect(page_state.vision_verification_models).to eq([ vision_verifier ])
      expect(page_state.vision_verification_model_ids).to eq([ vision_verifier.id ])
    end
  end

  describe '#save_posture_ready?' do
    it 'stays false when any cloud connector is still unconfigured' do
      expect(page_state.workflow_ready_count).to eq(2)
      expect(page_state.configured_cloud_import_provider_count).to eq(1)
      expect(page_state.save_posture_ready?).to eq(false)
    end

    it 'becomes true once workflows and cloud connectors are fully configured' do
      allow(view_context).to receive(:cloud_import_provider_states_for_settings).and_return(
        [
          { key: 'google_drive', configured: true },
          { key: 'dropbox', configured: true }
        ]
      )

      expect(page_state.configured_cloud_import_provider_count).to eq(2)
      expect(page_state.save_posture_ready?).to eq(true)
    end
  end
end
