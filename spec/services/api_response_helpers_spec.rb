require 'rails_helper'

RSpec.describe 'ApiResponseHelpers' do
  describe '#fake_llm_completion_response' do
    it 'builds a chat completion payload with predictable top-level attributes' do
      response = fake_llm_completion_response(
        content: 'Reworked onboarding copy to improve activation.',
        model: 'gpt-4.1-mini',
        response_id: 'chatcmpl_demo_123',
        created_at: 1_700_000_123
      )

      expect(response).to include(
        'id' => 'chatcmpl_demo_123',
        'object' => 'chat.completion',
        'created' => 1_700_000_123,
        'model' => 'gpt-4.1-mini'
      )
      expect(response.fetch('choices').first.fetch('message')).to include(
        'role' => 'assistant',
        'content' => 'Reworked onboarding copy to improve activation.'
      )
      expect(response.fetch('usage')).to include('prompt_tokens', 'completion_tokens', 'total_tokens')
    end
  end

  describe '#fake_api_error_response' do
    it 'builds an API-style error payload' do
      response = fake_api_error_response(status: 422, message: 'Invalid request payload')

      expect(response).to eq(
        'error' => {
          'message' => 'Invalid request payload',
          'type' => 'api_error',
          'code' => 422
        }
      )
    end
  end
end
