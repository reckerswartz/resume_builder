require 'rails_helper'

RSpec.describe Llm::Providers::BaseClient do
  let(:provider) do
    create(
      :llm_provider,
      name: 'Example Provider',
      adapter: 'ollama',
      base_url: 'https://api.example.test/root/',
      settings: { 'request_timeout_seconds' => 12 }
    )
  end

  let(:client_class) do
    Class.new(described_class) do
      def fetch_json(path:, headers: {})
        send(:get_json, path: path, headers: headers)
      end

      def submit_json(path:, body:, headers: {})
        send(:post_json, path: path, body: body, headers: headers)
      end
    end
  end

  let(:client) { client_class.new(provider: provider) }

  def build_response(response_class, code:, body:)
    response_class.new('1.1', code.to_s, 'Response').tap do |response|
      response.instance_variable_set(:@read, true)
      response.instance_variable_set(:@body, body)
    end
  end

  describe '#get_json' do
    it 'normalizes the path, applies present headers, and returns parsed JSON' do
      response = build_response(Net::HTTPOK, code: 200, body: JSON.generate('models' => []))
      http = instance_double(Net::HTTP)
      captured_request = nil

      expect(http).to receive(:request) do |request|
        captured_request = request
        response
      end
      expect(Net::HTTP).to receive(:start)
        .with('api.example.test', 443, use_ssl: true, open_timeout: 12, read_timeout: 12)
        .and_yield(http)

      parsed = client.fetch_json(path: '/v1/models', headers: { 'Authorization' => 'Bearer token', 'X-Skip' => nil })

      expect(parsed).to eq('models' => [])
      expect(captured_request).to be_a(Net::HTTP::Get)
      expect(captured_request.path).to eq('/root/v1/models')
      expect(captured_request['Authorization']).to eq('Bearer token')
      expect(captured_request['X-Skip']).to be_nil
      expect(captured_request['Content-Type']).to be_nil
    end
  end

  describe '#post_json' do
    it 'compacts blank body keys, sends JSON, and returns parsed JSON' do
      response = build_response(Net::HTTPOK, code: 200, body: JSON.generate('id' => 'req-123'))
      http = instance_double(Net::HTTP)
      captured_request = nil

      expect(http).to receive(:request) do |request|
        captured_request = request
        response
      end
      expect(Net::HTTP).to receive(:start)
        .with('api.example.test', 443, use_ssl: true, open_timeout: 12, read_timeout: 12)
        .and_yield(http)

      parsed = client.submit_json(
        path: 'v1/chat/completions',
        body: { model: 'llama-3.1', optional: nil },
        headers: { 'X-Trace-Id' => 'trace-123', 'X-Skip' => '' }
      )

      expect(parsed).to eq('id' => 'req-123')
      expect(captured_request).to be_a(Net::HTTP::Post)
      expect(captured_request.path).to eq('/root/v1/chat/completions')
      expect(captured_request['Content-Type']).to include('application/json')
      expect(captured_request['X-Trace-Id']).to eq('trace-123')
      expect(captured_request['X-Skip']).to be_nil
      expect(JSON.parse(captured_request.body)).to eq('model' => 'llama-3.1')
    end
  end

  describe 'request failures' do
    it 'raises the parsed error message from an error payload hash' do
      response = build_response(Net::HTTPBadRequest, code: 400, body: JSON.generate('error' => { 'message' => 'Request invalid.' }))
      http = instance_double(Net::HTTP, request: response)

      expect(Net::HTTP).to receive(:start)
        .with('api.example.test', 443, use_ssl: true, open_timeout: 12, read_timeout: 12)
        .and_yield(http)

      expect do
        client.fetch_json(path: '/v1/models')
      end.to raise_error(StandardError, 'Request invalid.')
    end

    it 'falls back to the response code when no error details are present' do
      response = build_response(Net::HTTPInternalServerError, code: 500, body: JSON.generate({}))
      http = instance_double(Net::HTTP, request: response)

      expect(Net::HTTP).to receive(:start)
        .with('api.example.test', 443, use_ssl: true, open_timeout: 12, read_timeout: 12)
        .and_yield(http)

      expect do
        client.fetch_json(path: '/v1/models')
      end.to raise_error(StandardError, 'Request failed with status 500.')
    end

    it 'raises a clear error for invalid JSON responses' do
      response = build_response(Net::HTTPOK, code: 200, body: 'not-json')
      http = instance_double(Net::HTTP, request: response)

      expect(Net::HTTP).to receive(:start)
        .with('api.example.test', 443, use_ssl: true, open_timeout: 12, read_timeout: 12)
        .and_yield(http)

      expect do
        client.fetch_json(path: '/v1/models')
      end.to raise_error(StandardError, 'Received an invalid JSON response from Example Provider.')
    end

    it 'wraps timeout errors with the provider name' do
      expect(Net::HTTP).to receive(:start)
        .with('api.example.test', 443, use_ssl: true, open_timeout: 12, read_timeout: 12)
        .and_raise(Timeout::Error, 'execution expired')

      expect do
        client.fetch_json(path: '/v1/models')
      end.to raise_error(StandardError, 'Example Provider request failed: execution expired')
    end
  end

  describe '#generate_image_variations' do
    it 'raises a provider-specific not implemented error' do
      base_client = described_class.new(provider: provider)

      expect do
        base_client.generate_image_variations(model: double('model'), prompt: 'Generate variations', images: [])
      end.to raise_error(NotImplementedError, 'Example Provider does not implement image generation yet.')
    end
  end

  describe '#verify_image_candidate' do
    it 'raises a provider-specific not implemented error' do
      base_client = described_class.new(provider: provider)

      expect do
        base_client.verify_image_candidate(model: double('model'), prompt: 'Verify candidate', images: [])
      end.to raise_error(NotImplementedError, 'Example Provider does not implement image verification yet.')
    end
  end
end
