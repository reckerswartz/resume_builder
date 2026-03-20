require "mini_magick"

module Photos
  class EnhancementService
    OUTPUT_EXTENSION = ".jpg".freeze
    OUTPUT_CONTENT_TYPE = "image/jpeg".freeze

    Result = Data.define(:success, :source_asset, :asset, :metadata, :error_message) do
      def success?
        success
      end
    end

    def initialize(source_asset:)
      @source_asset = source_asset
    end

    def call
      Photos::TempfileManager.with_downloaded_attachment(source_asset.file, basename: "photo-enhance-source") do |input|
        Photos::TempfileManager.with_tempfile(basename: enhanced_basename, extension: OUTPUT_EXTENSION) do |output|
          process_image(input.path, output.path)
          metadata = processed_metadata(output.path)
          asset = Photos::AssetBuilder.new(
            photo_profile: source_asset.photo_profile,
            source_asset: source_asset,
            asset_kind: :enhanced,
            file_io: output,
            filename: enhanced_filename,
            content_type: OUTPUT_CONTENT_TYPE,
            metadata: metadata,
            status: :ready
          ).call

          return Result.new(
            success: true,
            source_asset: source_asset,
            asset: asset,
            metadata: metadata,
            error_message: nil
          )
        end
      end
    rescue StandardError => error
      Result.new(
        success: false,
        source_asset: source_asset,
        asset: nil,
        metadata: {},
        error_message: error.message
      )
    end

    private
      attr_reader :source_asset

      def process_image(input_path, output_path)
        image = MiniMagick::Image.open(input_path)
        image.auto_orient
        image.strip
        image.colorspace("sRGB")
        image.resize("1400x1400>")
        image.unsharp("0x0.75+0.75+0.008")
        image.contrast
        image.quality("90")
        image.format("jpg")
        image.write(output_path)
      end

      def processed_metadata(path)
        image = MiniMagick::Image.open(path)

        {
          "content_type" => OUTPUT_CONTENT_TYPE,
          "width" => image.width,
          "height" => image.height,
          "processing_step" => "enhanced",
          "source_asset_id" => source_asset.id,
          "enhanced_at" => Time.current.iso8601,
          "enhancement_stack" => [ "auto_orient", "strip", "resize", "unsharp", "contrast" ]
        }
      end

      def enhanced_basename
        "photo-enhanced-#{source_asset.id}"
      end

      def enhanced_filename
        "#{File.basename(source_asset.display_name, ".*")}-enhanced.jpg"
      end
  end
end
