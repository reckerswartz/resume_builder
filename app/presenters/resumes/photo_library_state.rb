module Resumes
  class PhotoLibraryState
    def initialize(resume:, view_context:)
      @resume = resume
      @view_context = view_context
    end

    def enabled?
      view_context.feature_enabled?("photo_processing")
    end

    def profile
      @profile ||= resume.photo_profile || current_user.photo_profiles.includes(photo_assets: [ file_attachment: :blob ]).order(updated_at: :desc).first
    end

    def profile_present?
      profile.present?
    end

    def supports_headshot_template?
      resume.template.normalized_layout_config.fetch("supports_headshot")
    end

    def selected_asset
      @selected_asset ||= resume.selected_headshot_photo_asset
    end

    def selected_asset_id
      selected_asset&.id
    end

    def asset_cards
      return [] unless profile_present?

      profile.photo_assets
        .includes(file_attachment: :blob)
        .to_a
        .sort_by { |asset| [ asset.ready? ? 0 : 1, asset.selection_priority, -asset.updated_at.to_i ] }
        .map do |asset|
          {
            asset: asset,
            id: asset.id,
            selected: asset.id == selected_asset_id,
            preview_url: view_context.url_for(asset.file),
            destroy_path: view_context.photo_profile_photo_asset_path(profile, asset, resume_id: resume.id, return_to: return_to_path),
            background_remove_path: background_remove_path_for(asset),
            generate_for_template_path: generate_for_template_path_for(asset),
            verify_path: verify_path_for(asset),
            badges: asset_badges(asset)
          }
        end
    end

    def recent_runs
      return [] unless profile_present?

      profile.photo_processing_runs.recent.limit(6)
    end

    def create_profile_path
      view_context.photo_profiles_path(resume_id: resume.id, return_to: return_to_path)
    end

    def upload_path
      return if profile.blank?

      view_context.photo_profile_photo_assets_path(profile, resume_id: resume.id, return_to: return_to_path)
    end

    def generation_enabled?
      enabled? && view_context.feature_enabled?("resume_image_generation") && view_context.llm_role_enabled?("vision_generation")
    end

    def verification_enabled?
      enabled? && view_context.feature_enabled?("resume_image_generation") && view_context.llm_role_enabled?("vision_verification")
    end

    def workflow_label(run)
      I18n.t("resumes.editor_personal_details_step.photo_library.recent_runs.workflow_types.#{run.workflow_type}")
    end

    def run_status_label(run)
      I18n.t("resumes.editor_personal_details_step.photo_library.recent_runs.statuses.#{run.status}")
    end

    private
      attr_reader :resume, :view_context

      def asset_badges(asset)
        [
          asset_kind_label(asset),
          asset_status_label(asset),
          dimensions_label(asset)
        ].compact
      end

      def asset_kind_label(asset)
        I18n.t("resumes.editor_personal_details_step.photo_library.asset_badges.asset_kind.#{asset.asset_kind}")
      end

      def asset_status_label(asset)
        I18n.t("resumes.editor_personal_details_step.photo_library.asset_badges.status.#{asset.status}")
      end

      def background_remove_path_for(asset)
        return unless generation_enabled?

        view_context.background_remove_photo_profile_photo_asset_path(profile, asset, resume_id: resume.id, return_to: return_to_path)
      end

      def current_user
        view_context.current_user
      end

      def dimensions_label(asset)
        return if asset.width.blank? || asset.height.blank?

        I18n.t("resumes.editor_personal_details_step.photo_library.asset_badges.dimensions", width: asset.width, height: asset.height)
      end

      def generate_for_template_path_for(asset)
        return unless generation_enabled? && supports_headshot_template?

        view_context.generate_for_template_photo_profile_photo_asset_path(profile, asset, resume_id: resume.id, return_to: return_to_path)
      end

      def return_to_path
        @return_to_path ||= view_context.request&.fullpath.presence || view_context.edit_resume_path(resume, step: "personal_details")
      end

      def verify_path_for(asset)
        return unless verification_enabled?

        view_context.verify_photo_profile_photo_asset_path(profile, asset, resume_id: resume.id, return_to: return_to_path)
      end
  end
end
