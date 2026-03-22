require 'rails_helper'

RSpec.describe Llm::Providers::NvidiaBuildClient do
  let(:provider) { create(:llm_provider, :nvidia_build, api_key_env_var: 'nvapi-1234567890abcdef') }
  let(:client) { described_class.new(provider: provider) }

  describe '#fetch_models' do
    it 'fetches models with authorization and returns deep-stringified model payloads' do
      stub_request(:get, "#{provider.base_url}/v1/models")
        .with(headers: { 'Authorization' => "Bearer #{provider.api_key}" })
        .to_return(
          status: 200,
          body: JSON.generate(
            data: [
              {
                id: 'google/gemma-2-9b-it',
                details: {
                  family: :gemma,
                  parameter_size: '9B'
                }
              }
            ]
          ),
          headers: { 'Content-Type' => 'application/json' }
        )

      models = client.fetch_models

      expect(models).to eq([
        {
          'id' => 'google/gemma-2-9b-it',
          'details' => {
            'family' => 'gemma',
            'parameter_size' => '9B'
          }
        }
      ])
    end
  end

  describe '#generate_text' do
    it 'posts chat completions with the expected payload and returns normalized content, token usage, and metadata' do
      model = create(
        :llm_model,
        llm_provider: provider,
        identifier: 'meta/llama-3.1-70b-instruct',
        settings: { 'temperature' => 0.4, 'max_output_tokens' => 256 }
      )
      prompt = 'Return valid JSON only.'

      request_stub = stub_request(:post, "#{provider.base_url}/v1/chat/completions")
        .with do |request|
          body = JSON.parse(request.body)

          request.headers['Authorization'] == "Bearer #{provider.api_key}" &&
            request.headers['Content-Type']&.include?('application/json') &&
            body == {
              'model' => model.identifier,
              'messages' => [
                {
                  'role' => 'system',
                  'content' => 'You are a precise resume analysis assistant. Return valid JSON only.'
                },
                {
                  'role' => 'user',
                  'content' => prompt
                }
              ],
              'temperature' => 0.4,
              'max_tokens' => 256
            }
        end
        .to_return(
          status: 200,
          body: JSON.generate(
            id: 'req-123',
            model: model.identifier,
            usage: {
              prompt_tokens: 11,
              completion_tokens: 7,
              total_tokens: 18
            },
            choices: [
              {
                message: {
                  content: '{"summary":"Ready"}'
                }
              }
            ]
          ),
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.generate_text(model:, prompt:)

      expect(request_stub).to have_been_requested.once
      expect(response[:content]).to eq('{"summary":"Ready"}')
      expect(response[:token_usage]).to eq(
        'prompt_tokens' => 11,
        'completion_tokens' => 7,
        'total_tokens' => 18
      )
      expect(response[:metadata]).to eq(
        'id' => 'req-123',
        'model' => model.identifier,
        'usage' => {
          'prompt_tokens' => 11,
          'completion_tokens' => 7,
          'total_tokens' => 18
        }
      )
    end

    it 'raises a clear error when the provider has no resolvable api key' do
      provider = create(:llm_provider, :nvidia_build, api_key_env_var: 'MISSING_NVIDIA_KEY')
      model = create(:llm_model, llm_provider: provider)
      client = described_class.new(provider: provider)

      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('MISSING_NVIDIA_KEY').and_return(nil)

      expect do
        client.generate_text(model:, prompt: 'Return JSON only.')
      end.to raise_error(StandardError, /needs a valid API key reference or token/)
    end
  end
end
