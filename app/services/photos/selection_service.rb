module Photos
  class SelectionService
    Result = Data.define(:success, :selection, :resume, :error_message) do
      def success?
        success
      end
    end

    def initialize(resume:, photo_asset:, slot_name: "headshot", template: nil)
      @photo_asset = photo_asset
      @resume = resume
      @slot_name = slot_name.to_s
      @template = template || resume.template
    end

    def call
      return clear_selection if photo_asset.blank?
      return failure(I18n.t("resumes.photo_library.selection_service.asset_user_mismatch")) unless photo_asset.photo_profile.user_id == resume.user_id

      ActiveRecord::Base.transaction do
        resume.update!(photo_profile: photo_asset.photo_profile) if resume.photo_profile_id != photo_asset.photo_profile_id

        selection = resume.resume_photo_selections.find_or_initialize_by(
          template: template,
          slot_name: slot_name
        )
        selection.photo_asset = photo_asset
        selection.status = :active
        selection.save!

        return Result.new(success: true, selection: selection, resume: resume.reload, error_message: nil)
      end
    rescue ActiveRecord::RecordInvalid => error
      failure(error.record.errors.full_messages.to_sentence)
    end

    private
      attr_reader :photo_asset, :resume, :slot_name, :template

      def clear_selection
        selection = resume.resume_photo_selections.find_by(template: template, slot_name: slot_name)
        selection&.destroy!
        Result.new(success: true, selection: nil, resume: resume.reload, error_message: nil)
      end

      def failure(message)
        Result.new(success: false, selection: nil, resume: resume, error_message: message)
      end
  end
end
