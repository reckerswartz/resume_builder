require 'rails_helper'

RSpec.describe Llm::Providers::OllamaClient do
  let(:provider) { create(:llm_provider) }
  let(:client) { described_class.new(provider: provider) }

  describe '#fetch_models' do
    it 'fetches tags and returns deep-stringified model payloads' do
      stub_request(:get, "#{provider.base_url}/api/tags")
        .to_return(
          status: 200,
          body: JSON.generate(
            models: [
              {
                name: 'llama3.1:8b',
                details: {
                  family: :llama,
                  parameter_size: '8B'
                }
              }
            ]
          ),
          headers: { 'Content-Type' => 'application/json' }
        )

      models = client.fetch_models

      expect(models).to eq([
        {
          'name' => 'llama3.1:8b',
          'details' => {
            'family' => 'llama',
            'parameter_size' => '8B'
          }
        }
      ])
    end
  end

  describe '#generate_text' do
    it 'posts generate requests with the expected payload and returns normalized content, token usage, and metadata' do
      model = create(
        :llm_model,
        llm_provider: provider,
        identifier: 'llama3.1:8b',
        settings: { 'temperature' => 0.4, 'max_output_tokens' => 256 }
      )
      prompt = 'Return valid JSON only.'

      request_stub = stub_request(:post, "#{provider.base_url}/api/generate")
        .with do |request|
          body = JSON.parse(request.body)

          request.headers['Content-Type']&.include?('application/json') &&
            body == {
              'model' => model.identifier,
              'prompt' => prompt,
              'stream' => false,
              'format' => 'json',
              'options' => {
                'temperature' => 0.4,
                'num_predict' => 256
              }
            }
        end
        .to_return(
          status: 200,
          body: JSON.generate(
            model: model.identifier,
            created_at: '2026-03-21T21:23:00Z',
            response: '{"summary":"Ready"}',
            prompt_eval_count: 11,
            eval_count: 7,
            done: true
          ),
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.generate_text(model:, prompt:)

      expect(request_stub).to have_been_requested.once
      expect(response[:content]).to eq('{"summary":"Ready"}')
      expect(response[:token_usage]).to eq(
        'input_tokens' => 11,
        'output_tokens' => 7
      )
      expect(response[:metadata]).to eq(
        'model' => model.identifier,
        'created_at' => '2026-03-21T21:23:00Z',
        'prompt_eval_count' => 11,
        'eval_count' => 7,
        'done' => true
      )
    end

    it 'omits blank ollama options and compacts blank token usage values' do
      model = create(
        :llm_model,
        llm_provider: provider,
        identifier: 'llama3.1:8b',
        settings: {}
      )

      request_stub = stub_request(:post, "#{provider.base_url}/api/generate")
        .with do |request|
          body = JSON.parse(request.body)

          body == {
            'model' => model.identifier,
            'prompt' => 'Return valid JSON only.',
            'stream' => false,
            'format' => 'json',
            'options' => {}
          }
        end
        .to_return(
          status: 200,
          body: JSON.generate(
            model: model.identifier,
            response: '{"summary":"Ready"}',
            prompt_eval_count: nil,
            eval_count: nil,
            done: true
          ),
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.generate_text(model:, prompt: 'Return valid JSON only.')

      expect(request_stub).to have_been_requested.once
      expect(response[:token_usage]).to eq({})
      expect(response[:metadata]).to eq(
        'model' => model.identifier,
        'prompt_eval_count' => nil,
        'eval_count' => nil,
        'done' => true
      )
    end
  end
end
