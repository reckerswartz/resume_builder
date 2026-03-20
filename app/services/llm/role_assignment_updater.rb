module Llm
  class RoleAssignmentUpdater
    Result = Data.define(:success, :errors) do
      def success?
        success
      end
    end

    def initialize(role_model_ids:)
      @role_model_ids = LlmModelAssignment::ROLES.index_with do |role|
        Array(role_model_ids.to_h.stringify_keys.fetch(role, [])).reject(&:blank?).map(&:to_i).uniq
      end
      @errors = []
    end

    def call
      validate_role_model_ids
      return Result.new(success: false, errors: errors) if errors.any?

      LlmModelAssignment.transaction do
        role_model_ids.each do |role, model_ids|
          sync_role(role, model_ids)
        end
      end

      Result.new(success: true, errors: [])
    rescue ActiveRecord::RecordInvalid => error
      Result.new(success: false, errors: [ error.record.errors.full_messages.to_sentence ])
    end

    private
      attr_reader :errors, :role_model_ids

      def validate_role_model_ids
        role_model_ids.each do |role, model_ids|
          if LlmModelAssignment::GENERATION_ROLES.include?(role) && model_ids.many?
            errors << "#{role.humanize} can only have one primary model."
          end

          models_by_id = LlmModel.includes(:llm_provider).where(id: model_ids).index_by(&:id)

          if models_by_id.size != model_ids.size
            errors << "#{role.humanize} includes an unknown model."
            next
          end

          models_by_id.each_value do |llm_model|
            next if llm_model.supports_role?(role)

            errors << "#{llm_model.name} does not support #{role.humanize.downcase}."
          end
        end
      end

      def sync_role(role, model_ids)
        existing_assignments = LlmModelAssignment.where(role: role)
        if model_ids.any?
          existing_assignments.where.not(llm_model_id: model_ids).destroy_all
        else
          existing_assignments.destroy_all
        end

        model_ids.each_with_index do |model_id, position|
          assignment = LlmModelAssignment.find_or_initialize_by(role: role, llm_model_id: model_id)
          assignment.position = position
          assignment.save!
        end
      end
  end
end
