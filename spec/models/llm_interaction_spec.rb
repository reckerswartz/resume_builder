require 'rails_helper'

RSpec.describe LlmInteraction, type: :model do
  describe 'callbacks' do
    it 'stringifies token usage and metadata keys' do
      interaction = described_class.create!(
        user: create(:user),
        resume: create(:resume),
        feature_name: 'resume_suggestions',
        status: 'queued',
        token_usage: { input_tokens: 20 },
        metadata: { entry_id: 10 }
      )

      expect(interaction.token_usage).to eq('input_tokens' => 20)
      expect(interaction.metadata).to eq('entry_id' => 10)
      expect(interaction).to be_queued
    end
  end
end
