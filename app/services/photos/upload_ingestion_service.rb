module Photos
  class UploadIngestionService
    MAX_FILES_PER_REQUEST = 6

    Result = Data.define(:success, :photo_profile, :created_assets, :duplicate_assets, :errors) do
      def success?
        success
      end

      def error_message
        errors.to_sentence
      end
    end

    def initialize(user:, uploaded_files:, photo_profile: nil)
      @photo_profile = photo_profile
      @uploaded_files = uploaded_files
      @user = user
    end

    def call
      files = normalized_uploaded_files
      return failure([ "Attach at least one photo to continue." ]) if files.blank?
      return failure([ "Upload up to #{MAX_FILES_PER_REQUEST} photos at a time." ]) if files.size > MAX_FILES_PER_REQUEST

      created_assets = []
      duplicate_assets = []
      errors = []

      files.each do |uploaded_file|
        source_asset = create_source_asset(uploaded_file)
        duplicate_asset = duplicate_for(source_asset)

        if duplicate_asset.present?
          source_asset.file.purge if source_asset.file.attached?
          source_asset.destroy!
          duplicate_assets << duplicate_asset
          next
        end

        created_assets << source_asset
        seed_selected_source_asset(source_asset)
        queue_normalization_for(source_asset)
      rescue ActiveRecord::RecordInvalid => error
        errors << error.record.errors.full_messages.to_sentence
      end

      Result.new(
        success: created_assets.any? || duplicate_assets.any?,
        photo_profile: resolved_photo_profile,
        created_assets: created_assets,
        duplicate_assets: duplicate_assets,
        errors: errors.uniq
      )
    end

    private
      attr_reader :photo_profile, :uploaded_files, :user

      def normalized_uploaded_files
        Array(uploaded_files).flatten.compact.reject(&:blank?)
      end

      def resolved_photo_profile
        @resolved_photo_profile ||= photo_profile || PhotoProfile.default_for(user)
      end

      def create_source_asset(uploaded_file)
        photo_asset = resolved_photo_profile.photo_assets.build(
          asset_kind: :source,
          status: :uploaded,
          metadata: {
            "display_name" => original_filename(uploaded_file),
            "content_type" => uploaded_file.content_type.to_s,
            "byte_size" => uploaded_file.size,
            "uploaded_at" => Time.current.iso8601
          }
        )
        photo_asset.file.attach(uploaded_file)
        photo_asset.save!
        photo_asset.attach_metadata!(
          "checksum" => photo_asset.file.blob.checksum,
          "content_type" => photo_asset.file.blob.content_type,
          "byte_size" => photo_asset.file.blob.byte_size
        )
        resolved_photo_profile.update!(status: :active) if resolved_photo_profile.draft?
        photo_asset
      end

      def duplicate_for(source_asset)
        resolved_photo_profile.photo_assets
          .where(asset_kind: :source)
          .where.not(id: source_asset.id)
          .where("photo_assets.metadata ->> 'checksum' = ?", source_asset.checksum.to_s)
          .where("photo_assets.metadata ->> 'byte_size' = ?", source_asset.byte_size.to_s)
          .first
      end

      def seed_selected_source_asset(source_asset)
        return if resolved_photo_profile.selected_source_photo_asset_id.present?

        resolved_photo_profile.update!(selected_source_photo_asset: source_asset)
      end

      def queue_normalization_for(source_asset)
        run = resolved_photo_profile.photo_processing_runs.create!(
          workflow_type: :normalize,
          status: :queued,
          input_asset_ids: [ source_asset.id ],
          metadata: {
            "source_asset_id" => source_asset.id,
            "source_filename" => source_asset.display_name
          }
        )
        PhotoNormalizeJob.perform_later(run.id, source_asset.id)
      end

      def failure(errors)
        Result.new(
          success: false,
          photo_profile: photo_profile,
          created_assets: [],
          duplicate_assets: [],
          errors: Array(errors)
        )
      end

      def original_filename(uploaded_file)
        uploaded_file.original_filename.to_s.presence || "uploaded-photo"
      end
  end
end
