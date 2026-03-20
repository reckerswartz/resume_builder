module Admin
  class SettingsUpdateService
    Result = Data.define(:success, :platform_setting) do
      def success?
        success
      end
    end

    def initialize(platform_setting:, platform_setting_params:, role_model_ids:)
      @platform_setting = platform_setting
      @platform_setting_params = platform_setting_params
      @role_model_ids = role_model_ids
    end

    def call
      success = false

      ActiveRecord::Base.transaction do
        platform_setting.update!(platform_setting_params)

        assignment_result = Llm::RoleAssignmentUpdater.new(role_model_ids: role_model_ids).call
        unless assignment_result.success?
          merge_assignment_errors(assignment_result.errors)
          raise ActiveRecord::Rollback
        end

        success = true
      end

      Result.new(success: success, platform_setting: platform_setting)
    rescue ActiveRecord::RecordInvalid
      Result.new(success: false, platform_setting: platform_setting)
    end

    private
      attr_reader :platform_setting, :platform_setting_params, :role_model_ids

      def merge_assignment_errors(messages)
        Array(messages).each do |message|
          platform_setting.errors.add(:base, message)
        end
      end
  end
end
