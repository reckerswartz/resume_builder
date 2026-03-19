require "vcr"
require "webmock/rspec"

VCR.configure do |config|
  config.cassette_library_dir = Rails.root.join("spec", "cassettes")
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.ignore_localhost = true
  config.allow_http_connections_when_no_cassette = false
  config.default_cassette_options = {
    record: ENV.fetch("VCR_RECORD_MODE", "once").to_sym,
    match_requests_on: %i[method uri body]
  }

  %w[OPENAI_API_KEY ANTHROPIC_API_KEY].each do |key|
    value = ENV[key]
    config.filter_sensitive_data("<#{key}>") { value } if value.present?
  end

  config.before_record do |interaction|
    %w[Authorization X-Api-Key].each do |header|
      next unless interaction.request.headers[header]

      interaction.request.headers[header] = ["<#{header.upcase.tr("-", "_")}>"]
    end

    interaction.response.headers.delete("Set-Cookie")
  end
end
