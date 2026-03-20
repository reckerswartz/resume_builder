require 'rails_helper'

RSpec.describe LlmInteraction, type: :model do
  describe 'callbacks' do
    it 'stringifies token usage and metadata keys and assigns provider from model' do
      llm_model = create(:llm_model)

      interaction = described_class.create!(
        user: create(:user),
        resume: create(:resume),
        llm_model: llm_model,
        feature_name: 'resume_suggestions',
        role: 'text_generation',
        status: 'queued',
        token_usage: { input_tokens: 20 },
        metadata: { entry_id: 10 }
      )

      expect(interaction.token_usage).to eq('input_tokens' => 20)
      expect(interaction.metadata).to eq('entry_id' => 10)
      expect(interaction).to be_queued
      expect(interaction.llm_provider).to eq(llm_model.llm_provider)
      expect(interaction.role).to eq('text_generation')
    end
  end
end
