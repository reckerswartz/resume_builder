module ApiResponseHelpers
  def fake_llm_completion_response(content: Faker::Lorem.paragraph(sentence_count: 2), model: "gpt-4o-mini", response_id: "chatcmpl_test_response", created_at: 1_700_000_000)
    prompt_tokens = Faker::Number.between(from: 80, to: 180)
    completion_tokens = Faker::Number.between(from: 20, to: 80)

    {
      "id" => response_id,
      "object" => "chat.completion",
      "created" => created_at,
      "model" => model,
      "choices" => [
        {
          "index" => 0,
          "message" => {
            "role" => "assistant",
            "content" => content
          },
          "finish_reason" => "stop"
        }
      ],
      "usage" => {
        "prompt_tokens" => prompt_tokens,
        "completion_tokens" => completion_tokens,
        "total_tokens" => prompt_tokens + completion_tokens
      }
    }
  end

  def fake_api_error_response(status: 429, message: nil)
    {
      "error" => {
        "message" => message || Faker::Lorem.sentence(word_count: 6),
        "type" => "api_error",
        "code" => status
      }
    }
  end
end

RSpec.configure do |config|
  config.include ApiResponseHelpers
end
