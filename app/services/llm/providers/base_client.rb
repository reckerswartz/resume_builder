require "json"
require "net/http"
require "uri"

module Llm
  module Providers
    class BaseClient
      def initialize(provider:)
        @provider = provider
      end

      private
        attr_reader :provider

        def get_json(path:, headers: {})
          request_json(http_method: Net::HTTP::Get, path:, headers:)
        end

        def post_json(path:, body:, headers: {})
          request_json(http_method: Net::HTTP::Post, path:, body:, headers:)
        end

        def request_json(http_method:, path:, body: nil, headers: {})
          uri = request_uri(path)
          request = http_method.new(uri)
          request["Content-Type"] = "application/json" if body.present?
          headers.each do |key, value|
            request[key] = value if value.present?
          end
          request.body = JSON.generate(body.compact) if body.present?

          response = Net::HTTP.start(
            uri.host,
            uri.port,
            use_ssl: uri.scheme == "https",
            open_timeout: provider.request_timeout_seconds,
            read_timeout: provider.request_timeout_seconds
          ) do |http|
            http.request(request)
          end

          parsed_body = response.body.present? ? JSON.parse(response.body) : {}
          raise StandardError, error_message(response, parsed_body) unless response.is_a?(Net::HTTPSuccess)

          parsed_body
        rescue JSON::ParserError
          raise StandardError, "Received an invalid JSON response from #{provider.name}."
        rescue SocketError, SystemCallError, Timeout::Error => error
          raise StandardError, "#{provider.name} request failed: #{error.message}"
        end

        def request_uri(path)
          URI.parse("#{provider.base_url.to_s.sub(%r{/+\z}, "")}/#{path.to_s.sub(%r{\A/+}, "")}")
        end

        def error_message(response, parsed_body)
          parsed_error = parsed_body["error"]
          details = case parsed_error
          when Hash
            parsed_error["message"]
          else
            parsed_error
          end

          details.presence || "Request failed with status #{response.code}."
        end
    end
  end
end
