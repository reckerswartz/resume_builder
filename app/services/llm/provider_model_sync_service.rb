module Llm
  class ProviderModelSyncService
    CATALOG_SOURCE = "provider_sync".freeze

    Result = Data.define(
      :success,
      :skipped,
      :provider,
      :models,
      :created_count,
      :updated_count,
      :deactivated_count,
      :error_message
    ) do
      def success?
        success
      end

      def skipped?
        skipped
      end
    end

    def initialize(provider:)
      @provider = provider
    end

    def call
      unless provider.syncable?
        message = provider.syncability_error || "#{provider.name} is not ready for model sync."
        persist_sync_error(message)
        return Result.new(
          success: false,
          skipped: true,
          provider: provider,
          models: [],
          created_count: 0,
          updated_count: 0,
          deactivated_count: 0,
          error_message: message
        )
      end

      synced_models = []
      created_count = 0
      updated_count = 0
      deactivated_count = 0

      ActiveRecord::Base.transaction do
        synced_models, created_count, updated_count = sync_models!
        deactivated_count = deactivate_missing_models!(synced_models.map(&:identifier))
        persist_sync_success(model_count: synced_models.size, created_count:, updated_count:, deactivated_count:)
      end

      Result.new(
        success: true,
        skipped: false,
        provider: provider,
        models: synced_models,
        created_count:,
        updated_count:,
        deactivated_count:,
        error_message: nil
      )
    rescue StandardError => error
      persist_sync_error(error.message)
      Result.new(
        success: false,
        skipped: false,
        provider: provider,
        models: [],
        created_count: 0,
        updated_count: 0,
        deactivated_count: 0,
        error_message: error.message
      )
    end

    private
      attr_reader :provider

      def sync_models!
        synced_models = []
        created_count = 0
        updated_count = 0

        normalized_remote_models.each_value do |normalized_model|

          llm_model = provider.llm_models.find_or_initialize_by(identifier: normalized_model.fetch(:identifier))
          created_count += 1 if llm_model.new_record?
          updated_count += 1 if llm_model.persisted?
          apply_attributes(llm_model, normalized_model)
          llm_model.save!
          synced_models << llm_model
        end

        [ synced_models, created_count, updated_count ]
      end

      def normalized_remote_models
        @normalized_remote_models ||= remote_models.each_with_object({}) do |remote_model, models_by_identifier|
          normalized_model = normalize_remote_model(remote_model)
          next if normalized_model.nil?

          models_by_identifier[normalized_model.fetch(:identifier)] = normalized_model
        end
      end

      def remote_models
        @remote_models ||= Array(client.fetch_models)
      end

      def client
        @client ||= ClientFactory.build(provider)
      end

      def normalize_remote_model(raw_attributes)
        raw_attributes = (raw_attributes || {}).deep_stringify_keys
        identifier = raw_attributes["id"].presence || raw_attributes["model"].presence || raw_attributes["name"].presence
        return if identifier.blank?

        inference = ModelCapabilityInference.new(identifier:, raw_attributes:).call

        {
          identifier:,
          name: raw_attributes["name"].presence || ModelCapabilityInference.display_name(identifier),
          supports_text: inference.fetch("supports_text"),
          supports_vision: inference.fetch("supports_vision"),
          metadata: build_metadata(raw_attributes, inference)
        }
      end

      def build_metadata(raw_attributes, inference)
        details = raw_attributes.fetch("details", {}).is_a?(Hash) ? raw_attributes.fetch("details", {}).deep_stringify_keys : {}

        {
          "catalog_source" => CATALOG_SOURCE,
          "sync_status" => "available",
          "model_type" => inference["model_type"],
          "input_modalities" => inference["input_modalities"],
          "output_modalities" => inference["output_modalities"],
          "owned_by" => raw_attributes["owned_by"],
          "provider_object" => raw_attributes["object"],
          "provider_created_at" => provider_created_at(raw_attributes),
          "provider_updated_at" => raw_attributes["modified_at"],
          "family" => details["family"],
          "families" => Array(details["families"]).filter_map(&:presence),
          "format" => details["format"],
          "parameter_size" => details["parameter_size"],
          "quantization_level" => details["quantization_level"],
          "size" => raw_attributes["size"],
          "digest" => raw_attributes["digest"],
          "root" => raw_attributes["root"],
          "parent" => raw_attributes["parent"],
          "provider_payload" => raw_attributes,
          "synced_at" => Time.current.iso8601
        }.compact_blank
      end

      def provider_created_at(raw_attributes)
        created_value = raw_attributes["created"]
        return if created_value.blank?
        return Time.zone.at(created_value.to_i).iso8601 if created_value.to_s.match?(/\A\d+\z/)

        Time.zone.parse(created_value.to_s).iso8601
      rescue ArgumentError, TypeError
        created_value
      end

      def apply_attributes(llm_model, normalized_model)
        llm_model.name = normalized_model.fetch(:name)
        llm_model.supports_text = normalized_model.fetch(:supports_text)
        llm_model.supports_vision = normalized_model.fetch(:supports_vision)
        llm_model.active = true if llm_model.new_record?
        llm_model.active = true if llm_model.metadata["sync_status"] == "missing_from_provider"
        llm_model.metadata = llm_model.metadata.deep_stringify_keys.except("sync_status").merge(normalized_model.fetch(:metadata))
      end

      def deactivate_missing_models!(synced_identifiers)
        missing_scope = provider.llm_models
          .where("llm_models.metadata ->> 'catalog_source' = ?", CATALOG_SOURCE)
          .where.not(identifier: synced_identifiers)

        count = 0
        missing_scope.find_each do |llm_model|
          was_active = llm_model.active?
          llm_model.update!(
            active: false,
            metadata: llm_model.metadata.deep_stringify_keys.merge(
              "sync_status" => "missing_from_provider",
              "synced_at" => Time.current.iso8601
            )
          )
          count += 1 if was_active
        end
        count
      end

      def persist_sync_success(model_count:, created_count:, updated_count:, deactivated_count:)
        provider.update!(
          settings: provider.settings.deep_stringify_keys.merge(
            "last_sync_attempt_at" => Time.current.iso8601,
            "last_synced_at" => Time.current.iso8601,
            "last_synced_model_count" => model_count,
            "last_sync_created_count" => created_count,
            "last_sync_updated_count" => updated_count,
            "last_sync_deactivated_count" => deactivated_count,
            "last_sync_error" => nil
          )
        )
      end

      def persist_sync_error(message)
        provider.update!(
          settings: provider.settings.deep_stringify_keys.merge(
            "last_sync_attempt_at" => Time.current.iso8601,
            "last_sync_error" => message
          )
        )
      end
  end
end
