require "json"

module Llm
  class ResumeAutofillService
    Result = Data.define(:success, :resume, :interactions, :error_message) do
      def success?
        success
      end
    end

    CONTACT_FIELDS = %w[full_name email phone city country pin_code website linkedin].freeze
    FEATURE_NAME = "autofill_content".freeze
    SECTION_TYPES = %w[experience education skills].freeze
    TEXT_GENERATION_ROLE = "text_generation".freeze
    TEXT_VERIFICATION_ROLE = "text_verification".freeze

    def initialize(user:, resume:)
      @json_response_parser = JsonResponseParser.new
      @resume = resume
      @user = user
    end

    def call
      return skipped_result(I18n.t("resumes.resume_autofill_service.disabled")) unless feature_enabled?
      return skipped_result(source_content_result.error_message) unless source_content_result.success?

      generation_models = assigned_models_for(TEXT_GENERATION_ROLE)
      return skipped_result(I18n.t("resumes.resume_autofill_service.no_models")) if generation_models.blank?

      generation_executions = ParallelTextRunner.new(
        user: user,
        resume: resume,
        feature_name: FEATURE_NAME,
        role: TEXT_GENERATION_ROLE,
        prompt: generation_prompt_text,
        llm_models: generation_models,
        metadata: interaction_metadata
      ).call

      primary_execution = generation_executions.find(&:success?)
      return failure_result(generation_executions, I18n.t("resumes.resume_autofill_service.unavailable")) unless primary_execution

      generated_payload = normalized_payload(primary_execution.response_text)
      return failure_result(generation_executions, I18n.t("resumes.resume_autofill_service.invalid_payload")) if payload_blank?(generated_payload)

      verification_executions = verification_models.any? ? run_verification_models(generated_payload) : []
      merged_payload = merge_payloads(
        generated_payload,
        verification_executions.filter_map do |execution|
          next unless execution.success?

          normalized_payload(execution.response_text)
        end
      )

      Resume.transaction do
        apply_payload(merged_payload)
      end

      Result.new(
        success: true,
        resume: resume.reload,
        interactions: generation_executions.map(&:interaction) + verification_executions.map(&:interaction),
        error_message: nil
      )
    end

    private
      attr_reader :json_response_parser, :resume, :user

      def feature_enabled?
        PlatformSetting.current.feature_enabled?(FEATURE_NAME) && PlatformSetting.current.feature_enabled?("llm_access")
      end

      def source_content_result
        @source_content_result ||= Resumes::SourceTextResolver.new(resume: resume).call
      end

      def source_content_text
        source_content_result.text.to_s
      end

      def generation_prompt_text
        <<~PROMPT.squish
          Extract structured resume data from the provided resume source.
          Return valid JSON only in this exact shape:
          {"resume":{"title":"","headline":"","summary":"","contact_details":{"full_name":"","email":"","phone":"","city":"","country":"","pin_code":"","website":"","linkedin":""}},"sections":{"experience":[{"title":"","organization":"","location":"","remote":false,"start_date":"","end_date":"","current_role":false,"summary":"","highlights":[""]}],"education":[{"institution":"","degree":"","location":"","start_date":"","end_date":"","details":""}],"skills":[{"name":"","level":""}]}}
          Use empty strings, false, or empty arrays when information is missing.
          Source text JSON: #{source_content_text.to_json}
        PROMPT
      end

      def verification_prompt_text(generated_payload)
        <<~PROMPT.squish
          Review the structured resume extraction and add only missing details.
          Return valid JSON only in this exact shape:
          {"resume":{"title":"","headline":"","summary":"","contact_details":{"full_name":"","email":"","phone":"","city":"","country":"","pin_code":"","website":"","linkedin":""}},"sections":{"experience":[{"title":"","organization":"","location":"","remote":false,"start_date":"","end_date":"","current_role":false,"summary":"","highlights":[""]}],"education":[{"institution":"","degree":"","location":"","start_date":"","end_date":"","details":""}],"skills":[{"name":"","level":""}]}}
          Only include missing fields or missing entries. Use empty strings, false, or empty arrays for anything that should not change.
          Source text JSON: #{source_content_text.to_json}
          Current extraction JSON: #{generated_payload.to_json}
        PROMPT
      end

      def assigned_models_for(role)
        LlmModelAssignment.ready_models_for(role)
      end

      def verification_models
        @verification_models ||= assigned_models_for(TEXT_VERIFICATION_ROLE)
      end

      def run_verification_models(generated_payload)
        ParallelTextRunner.new(
          user: user,
          resume: resume,
          feature_name: FEATURE_NAME,
          role: TEXT_VERIFICATION_ROLE,
          prompt: verification_prompt_text(generated_payload),
          llm_models: verification_models,
          metadata: interaction_metadata
        ).call
      end

      def normalized_payload(response_text)
        payload = json_response_parser.object_from(response_text)
        resume_payload = payload.fetch("resume", payload)
        sections_payload = payload.fetch("sections", payload)

        {
          "resume" => normalize_resume_payload(resume_payload),
          "sections" => {
            "experience" => normalize_experience_entries(sections_payload.fetch("experience", sections_payload.fetch(:experience, []))),
            "education" => normalize_education_entries(sections_payload.fetch("education", sections_payload.fetch(:education, []))),
            "skills" => normalize_skill_entries(sections_payload.fetch("skills", sections_payload.fetch(:skills, [])))
          }
        }
      end

      def normalize_resume_payload(payload)
        payload = payload.is_a?(Hash) ? payload.deep_stringify_keys : {}

        {
          "title" => payload.fetch("title", "").to_s.squish,
          "headline" => payload.fetch("headline", "").to_s.squish,
          "summary" => payload.fetch("summary", "").to_s.squish,
          "contact_details" => normalize_contact_details(payload.fetch("contact_details", {}))
        }
      end

      def normalize_contact_details(payload)
        payload = payload.is_a?(Hash) ? payload.deep_stringify_keys : {}

        CONTACT_FIELDS.index_with do |field|
          payload.fetch(field, "").to_s.squish
        end
      end

      def normalize_experience_entries(values)
        Array(values).filter_map do |value|
          next unless value.is_a?(Hash)

          payload = value.deep_stringify_keys
          content = compact_string_fields(
            "title" => payload.fetch("title", "").to_s.squish,
            "organization" => payload.fetch("organization", "").to_s.squish,
            "location" => payload.fetch("location", "").to_s.squish,
            "start_date" => payload.fetch("start_date", "").to_s.squish,
            "end_date" => payload.fetch("end_date", "").to_s.squish,
            "summary" => payload.fetch("summary", "").to_s.squish
          )
          content["remote"] = ActiveModel::Type::Boolean.new.cast(payload["remote"])
          content["current_role"] = ActiveModel::Type::Boolean.new.cast(payload["current_role"])
          content["highlights"] = normalize_highlights(payload["highlights"])
          content["end_date"] = "Present" if content["current_role"] && content["end_date"].blank?
          next unless experience_entry_present?(content)

          content
        end
      end

      def normalize_education_entries(values)
        Array(values).filter_map do |value|
          next unless value.is_a?(Hash)

          content = compact_string_fields(
            value.deep_stringify_keys.slice("institution", "degree", "location", "start_date", "end_date", "details")
              .transform_values { |field_value| field_value.to_s.squish }
          )
          next unless education_entry_present?(content)

          content
        end
      end

      def normalize_skill_entries(values)
        Array(values).filter_map do |value|
          next unless value.is_a?(Hash)

          content = compact_string_fields(
            value.deep_stringify_keys.slice("name", "level")
              .transform_values { |field_value| field_value.to_s.squish }
          )
          next if content["name"].blank?

          content
        end
      end

      def normalize_highlights(values)
        Array(values.is_a?(String) ? values.lines : values).filter_map do |value|
          normalized = value.to_s.strip.sub(/\A[-*•]\s*/, "").squish
          normalized if normalized.present?
        end
      end

      def compact_string_fields(payload)
        payload.reject { |_key, value| value.respond_to?(:blank?) && value.blank? }
      end

      def experience_entry_present?(content)
        content.except("remote", "current_role").values.any?(&:present?) || content.fetch("highlights", []).any?
      end

      def education_entry_present?(content)
        content.values.any?(&:present?)
      end

      def payload_blank?(payload)
        resume_payload = payload.fetch("resume")
        contact_details = resume_payload.fetch("contact_details")

        resume_payload.except("contact_details").values.all?(&:blank?) &&
          contact_details.values.all?(&:blank?) &&
          SECTION_TYPES.all? { |section_type| payload.dig("sections", section_type).blank? }
      end

      def merge_payloads(base_payload, verification_payloads)
        verification_payloads.reduce(base_payload.deep_dup) do |merged_payload, verification_payload|
          merge_resume_payload!(merged_payload.fetch("resume"), verification_payload.fetch("resume", {}))

          SECTION_TYPES.each do |section_type|
            merged_payload["sections"][section_type] = merge_section_entries(
              merged_payload.dig("sections", section_type),
              verification_payload.dig("sections", section_type)
            )
          end

          merged_payload
        end
      end

      def merge_resume_payload!(base_payload, extra_payload)
        %w[title headline summary].each do |field|
          base_payload[field] = extra_payload[field].to_s.squish if base_payload[field].blank? && extra_payload[field].to_s.squish.present?
        end

        CONTACT_FIELDS.each do |field|
          extra_value = extra_payload.fetch("contact_details", {}).fetch(field, "").to_s.squish
          next if extra_value.blank?
          next if base_payload.fetch("contact_details", {}).fetch(field, "").present?

          base_payload["contact_details"][field] = extra_value
        end
      end

      def merge_section_entries(base_entries, extra_entries)
        Array(extra_entries).reduce(Array(base_entries).map(&:deep_dup)) do |merged_entries, extra_entry|
          match_index = merged_entries.index { |entry| section_entry_match?(entry, extra_entry) }

          if match_index.present?
            merged_entries[match_index] = merge_entry_payload(merged_entries[match_index], extra_entry)
          else
            merged_entries << extra_entry.deep_dup
          end

          merged_entries
        end
      end

      def section_entry_match?(base_entry, extra_entry)
        return false if base_entry.blank? || extra_entry.blank?

        entry_match_keys(base_entry, extra_entry).any? do |keys|
          keys.all? { |key| base_entry[key].present? && extra_entry[key].present? && base_entry[key] == extra_entry[key] }
        end
      end

      def entry_match_keys(base_entry, extra_entry)
        if base_entry.key?("organization") || extra_entry.key?("organization")
          [ %w[title organization start_date], %w[title organization], %w[organization start_date] ]
        elsif base_entry.key?("institution") || extra_entry.key?("institution")
          [ %w[institution degree start_date], %w[institution degree], %w[institution start_date] ]
        else
          [ %w[name], %w[name level] ]
        end
      end

      def merge_entry_payload(base_entry, extra_entry)
        merged_entry = base_entry.deep_dup

        extra_entry.each do |key, value|
          if key == "highlights"
            merged_entry[key] = (Array(merged_entry[key]) + Array(value)).map(&:to_s).map(&:squish).reject(&:blank?).uniq
          elsif value.is_a?(TrueClass) || value.is_a?(FalseClass)
            merged_entry[key] = value if merged_entry[key].blank? || merged_entry[key] == false
          elsif value.present? && merged_entry[key].blank?
            merged_entry[key] = value
          end
        end

        merged_entry
      end

      def apply_payload(payload)
        apply_resume_payload(payload.fetch("resume"))
        sync_sections(payload.fetch("sections"))
      end

      def apply_resume_payload(payload)
        contact_details = resume.contact_details.deep_dup
        contact_details.merge!(payload.fetch("contact_details").reject { |_key, value| value.blank? })

        resume.update!(
          title: payload.fetch("title").presence || resume.title,
          headline: payload.fetch("headline").presence || resume.headline,
          summary: payload.fetch("summary").presence || resume.summary,
          contact_details: contact_details
        )
      end

      def sync_sections(payload)
        SECTION_TYPES.each do |section_type|
          entries = Array(payload.fetch(section_type, []))
          section = resume.sections.find_or_initialize_by(section_type: section_type)
          next if section.new_record? && entries.empty?

          if section.new_record?
            section.position = (resume.sections.maximum(:position) || -1) + 1
          end

          section.title = ResumeBuilder::SectionRegistry.title_for(section_type) if section.title.blank?
          section.settings = (section.settings || {}).deep_stringify_keys
          section.save!
          section.entries.destroy_all

          entries.each_with_index do |content, index|
            section.entries.create!(content: content, position: index)
          end
        end
      end

      def skipped_result(message)
        interaction = resume.llm_interactions.create!(
          user: user,
          feature_name: FEATURE_NAME,
          role: TEXT_GENERATION_ROLE,
          status: :skipped,
          prompt: generation_prompt_text,
          response: message,
          token_usage: {},
          latency_ms: 0,
          metadata: interaction_metadata,
          error_message: message
        )

        Result.new(success: false, resume: resume, interactions: [ interaction ], error_message: message)
      end

      def failure_result(executions, message)
        Result.new(
          success: false,
          resume: resume,
          interactions: executions.map(&:interaction),
          error_message: executions.filter_map(&:error_message).first || message
        )
      end

      def interaction_metadata
        {
          "resume_id" => resume.id,
          "source_mode" => resume.source_mode,
          "source_kind" => source_content_result.source_kind,
          "source_content_type" => source_content_result.content_type,
          "source_text_characters" => source_content_text.length,
          "source_document_attached" => resume.source_document.attached?
        }
      end
  end
end
