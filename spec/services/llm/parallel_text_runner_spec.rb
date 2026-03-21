require 'rails_helper'

RSpec.describe Llm::ParallelTextRunner do
  let(:user) { create(:user) }
  let(:template) { create(:template) }
  let(:resume) { create(:resume, user:, template:) }
  let(:llm_provider) { create(:llm_provider) }
  let(:first_model) { create(:llm_model, llm_provider:, identifier: 'text-generator-1') }
  let(:second_model) { create(:llm_model, llm_provider:, identifier: 'text-generator-2') }
  let(:feature_name) { 'resume_suggestions' }
  let(:role) { 'text_generation' }
  let(:prompt) { 'Improve the resume content.' }
  let(:metadata) { { 'entry_id' => 123 } }

  describe '#call' do
    it 'returns an empty array when no models are provided' do
      result = described_class.new(
        user:,
        resume:,
        feature_name:,
        role:,
        prompt:,
        llm_models: [],
        metadata:
      ).call

      expect(result).to eq([])
      expect(resume.llm_interactions).to be_empty
    end

    it 'returns successful executions and persists interactions for each model' do
      provider_client = instance_double('ProviderClient')
      responses = {
        first_model.identifier => {
          content: '{"highlights":["Improved completion rate by 20%"]}',
          token_usage: { 'input_tokens' => 14, 'output_tokens' => 9 },
          metadata: { 'provider_request_id' => 'req-1' }
        },
        second_model.identifier => {
          content: '{"highlights":["Reduced editing time by 30%"]}',
          token_usage: { 'input_tokens' => 11, 'output_tokens' => 8 },
          metadata: { 'provider_request_id' => 'req-2' }
        }
      }

      allow(Llm::ClientFactory).to receive(:build).with(llm_provider).and_return(provider_client)
      allow(provider_client).to receive(:generate_text) do |model:, prompt:|
        responses.fetch(model.identifier)
      end

      executions = described_class.new(
        user:,
        resume:,
        feature_name:,
        role:,
        prompt:,
        llm_models: [ first_model, second_model ],
        metadata:
      ).call

      expect(executions.size).to eq(2)
      expect(executions).to all(be_success)
      expect(executions.map(&:llm_model)).to contain_exactly(first_model, second_model)
      expect(resume.llm_interactions.count).to eq(2)
      expect(provider_client).to have_received(:generate_text).with(model: first_model, prompt:)
      expect(provider_client).to have_received(:generate_text).with(model: second_model, prompt:)

      first_execution = executions.find { |execution| execution.llm_model == first_model }
      second_execution = executions.find { |execution| execution.llm_model == second_model }

      expect(first_execution.response_text).to eq('{"highlights":["Improved completion rate by 20%"]}')
      expect(first_execution.token_usage).to eq({ 'input_tokens' => 14, 'output_tokens' => 9 })
      expect(first_execution.metadata).to eq({ 'provider_request_id' => 'req-1' })
      expect(first_execution.error_message).to be_nil
      expect(first_execution.latency_ms).to be >= 0

      expect(second_execution.response_text).to eq('{"highlights":["Reduced editing time by 30%"]}')
      expect(second_execution.token_usage).to eq({ 'input_tokens' => 11, 'output_tokens' => 8 })
      expect(second_execution.metadata).to eq({ 'provider_request_id' => 'req-2' })
      expect(second_execution.error_message).to be_nil
      expect(second_execution.latency_ms).to be >= 0

      expect(first_execution.interaction).to have_attributes(
        user:,
        resume:,
        llm_model: first_model,
        llm_provider:,
        feature_name:,
        role:,
        status: 'succeeded',
        prompt:,
        response: first_execution.response_text,
        error_message: nil
      )
      expect(first_execution.interaction.token_usage).to eq({ 'input_tokens' => 14, 'output_tokens' => 9 })
      expect(first_execution.interaction.metadata).to include(
        'entry_id' => 123,
        'provider_request_id' => 'req-1',
        'llm_provider_slug' => llm_provider.slug,
        'llm_model_identifier' => first_model.identifier
      )

      expect(second_execution.interaction).to have_attributes(
        user:,
        resume:,
        llm_model: second_model,
        llm_provider:,
        feature_name:,
        role:,
        status: 'succeeded',
        prompt:,
        response: second_execution.response_text,
        error_message: nil
      )
      expect(second_execution.interaction.token_usage).to eq({ 'input_tokens' => 11, 'output_tokens' => 8 })
      expect(second_execution.interaction.metadata).to include(
        'entry_id' => 123,
        'provider_request_id' => 'req-2',
        'llm_provider_slug' => llm_provider.slug,
        'llm_model_identifier' => second_model.identifier
      )
    end

    it 'captures provider failures in the execution and interaction' do
      provider_client = instance_double('ProviderClient')

      allow(Llm::ClientFactory).to receive(:build).with(llm_provider).and_return(provider_client)
      allow(provider_client).to receive(:generate_text).with(model: first_model, prompt:).and_raise(StandardError, 'Provider unavailable')

      execution = described_class.new(
        user:,
        resume:,
        feature_name:,
        role:,
        prompt:,
        llm_models: [ first_model ],
        metadata:
      ).call.first

      expect(execution).not_to be_success
      expect(execution.response_text).to be_nil
      expect(execution.token_usage).to eq({})
      expect(execution.error_message).to eq('Provider unavailable')
      expect(execution.metadata).to eq({ 'exception_class' => 'StandardError' })
      expect(execution.latency_ms).to be >= 0

      expect(execution.interaction).to have_attributes(
        user:,
        resume:,
        llm_model: first_model,
        llm_provider:,
        feature_name:,
        role:,
        status: 'failed',
        prompt:,
        response: nil,
        error_message: 'Provider unavailable'
      )
      expect(execution.interaction.token_usage).to eq({})
      expect(execution.interaction.metadata).to include(
        'entry_id' => 123,
        'exception_class' => 'StandardError',
        'llm_provider_slug' => llm_provider.slug,
        'llm_model_identifier' => first_model.identifier
      )
    end
  end
end
