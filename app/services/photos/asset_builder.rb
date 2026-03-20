module Photos
  class AssetBuilder
    def initialize(photo_profile:, source_asset: nil, asset_kind:, file_io:, filename:, content_type:, metadata: {}, status: :ready)
      @asset_kind = asset_kind
      @content_type = content_type
      @file_io = file_io
      @filename = filename
      @metadata = metadata
      @photo_profile = photo_profile
      @source_asset = source_asset
      @status = status
    end

    def call
      photo_asset = photo_profile.photo_assets.build(
        source_asset: source_asset,
        asset_kind: asset_kind,
        status: status,
        metadata: metadata
      )
      file_io.rewind if file_io.respond_to?(:rewind)
      photo_asset.file.attach(io: file_io, filename: filename, content_type: content_type)
      photo_asset.save!
      photo_asset.attach_metadata!(attachment_metadata(photo_asset))
      photo_asset
    end

    private
      attr_reader :asset_kind, :content_type, :file_io, :filename, :metadata, :photo_profile, :source_asset, :status

      def attachment_metadata(photo_asset)
        {
          "content_type" => photo_asset.file.blob.content_type,
          "byte_size" => photo_asset.file.blob.byte_size,
          "checksum" => photo_asset.file.blob.checksum,
          "display_name" => filename.to_s
        }.compact_blank
      end
  end
end
