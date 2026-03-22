module Errors
  class Tracker
    def self.capture(error:, source:, context: {}, occurred_at: Time.current, duration_ms: nil)
      new(error:, source:, context:, occurred_at:, duration_ms:).capture
    end

    def initialize(error:, source:, context:, occurred_at:, duration_ms:)
      @error = error
      @source = source
      @context = context
      @occurred_at = occurred_at
      @duration_ms = duration_ms
    end

    def capture
      error_log = ErrorLog.create!(
        source: source,
        error_class: error.class.name,
        message: error.message.to_s,
        context: normalized_context,
        backtrace_lines: Array(error.backtrace).first(25),
        occurred_at: occurred_at,
        duration_ms: duration_ms
      )

      Rails.logger.error(log_message(error_log))

      error_log
    rescue StandardError => tracking_error
      Rails.logger.error(
        "Error tracking failed for #{error.class.name}: #{error.message} " \
        "(tracking error: #{tracking_error.class}: #{tracking_error.message})"
      )
      nil
    end

    private
      attr_reader :error, :source, :context, :occurred_at, :duration_ms

      def normalized_context
        (context || {}).as_json
      end

      def log_message(error_log)
        context_fragments = []
        context_fragments << "request_id=#{error_log.context['request_id']}" if error_log.context["request_id"].present?
        context_fragments << "active_job_id=#{error_log.context['active_job_id']}" if error_log.context["active_job_id"].present?

        details = context_fragments.any? ? " #{context_fragments.join(' ')}" : ""

        "[#{error_log.reference_id}] #{error_log.error_class}: #{error_log.message} " \
        "(source=#{error_log.source}, occurred_at=#{error_log.occurred_at.iso8601})#{details}"
      end
  end
end
