require 'rails_helper'

RSpec.describe Llm::ResumeSuggestionService do
  let(:user) { create(:user) }
  let(:resume) { create(:resume, user:) }
  let(:section) { create(:section, resume:, section_type: 'experience', position: 0) }
  let(:entry) { create(:entry, section:, content: { 'title' => 'Engineer', 'organization' => 'Acme', 'highlights' => ['improved search quality'] }) }
  let(:llm_provider) { create(:llm_provider) }
  let(:generation_model) { create(:llm_model, llm_provider:, identifier: 'generator-model') }
  let(:verification_model) { create(:llm_model, llm_provider:, identifier: 'verifier-model') }
  let!(:generation_assignment) { create(:llm_model_assignment, llm_model: generation_model, role: 'text_generation') }
  let!(:verification_assignment) { create(:llm_model_assignment, llm_model: verification_model, role: 'text_verification') }
  let(:provider_client_class) do
    Class.new do
      def initialize(responses)
        @responses = responses
      end

      def generate_text(model:, prompt:)
        @responses.fetch(model.identifier)
      end
    end
  end
  let(:provider_client) do
    provider_client_class.new(
      generation_model.identifier => {
        content: '{"highlights":["Delivered improved search quality"]}',
        token_usage: { 'input_tokens' => 12, 'output_tokens' => 7 },
        metadata: { 'source' => 'generation-spec' }
      },
      verification_model.identifier => {
        content: '{"missing_highlights":["Reduced triage time by 30%"]}',
        token_usage: { 'input_tokens' => 10, 'output_tokens' => 6 },
        metadata: { 'source' => 'verification-spec' }
      }
    )
  end

  before do
    PlatformSetting.current.update!(
      feature_flags: {
        'llm_access' => true,
        'resume_suggestions' => true,
        'autofill_content' => false
      },
      preferences: PlatformSetting.current.preferences
    )

    allow(Llm::ClientFactory).to receive(:build).and_return(provider_client)
  end

  describe '#call' do
    it 'merges generated highlights with verification feedback and logs interactions' do
      result = described_class.new(user:, entry:).call

      expect(result).to be_success
      expect(result.content['highlights']).to eq([
        'Delivered improved search quality',
        'Reduced triage time by 30%'
      ])
      expect(result.interactions.size).to eq(2)
      expect(result.interactions.map(&:role)).to contain_exactly('text_generation', 'text_verification')
      expect(result.interactions.map(&:llm_model)).to contain_exactly(generation_model, verification_model)
    end
  end
end
