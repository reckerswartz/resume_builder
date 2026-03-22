FactoryBot.define do
  factory :error_log do
    sequence(:reference_id) { |n| "ERR-20260319-#{n.to_s.rjust(4, '0')}" }
    source { "request" }
    error_class { "StandardError" }
    message { "Something went wrong" }
    context do
      {
        "request_id" => "req-123",
        "path" => "/resumes",
        "method" => "GET",
        "user_id" => 1
      }
    end
    backtrace_lines { [ "app/controllers/resumes_controller.rb:10:in `index'" ] }
    duration_ms { 210 }
    occurred_at { Time.current }

    trait :job do
      source { "job" }
      context do
        {
          "active_job_id" => "job-123",
          "job_type" => "ResumeExportJob",
          "queue_name" => "default",
          "job_log_id" => 1
        }
      end
    end
  end
end
