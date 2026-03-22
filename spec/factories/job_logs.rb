FactoryBot.define do
  factory :job_log do
    sequence(:active_job_id) { |n| "job-#{n}" }
    job_type { "ResumeExportJob" }
    queue_name { "default" }
    status { "queued" }
    input { { "arguments" => [ 1, 1 ] } }
    output { {} }
    error_details { {} }
    duration_ms { nil }
    started_at { Time.current }
    finished_at { nil }

    trait :succeeded do
      status { "succeeded" }
      output { { "filename" => "resume.pdf" } }
      duration_ms { 420 }
      finished_at { Time.current }
    end

    trait :failed do
      status { "failed" }
      error_details { { "message" => "Something went wrong" } }
      duration_ms { 420 }
      finished_at { Time.current }
    end
  end
end
