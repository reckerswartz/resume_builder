require "fileutils"

module Photos
  class EnhancementService
    TARGET_LIMIT = 1400

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
        Photos::TempfileManager.with_tempfile(basename: enhanced_basename, extension: output_extension) do |output|
          processing_metadata = process_image(input.path, output.path)
          metadata = processed_metadata(output.path, processing_metadata:)
          asset = Photos::AssetBuilder.new(
            photo_profile: source_asset.photo_profile,
            source_asset: source_asset,
            asset_kind: :enhanced,
            file_io: output,
            filename: enhanced_filename,
            content_type: output_content_type,
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
        load_vips!
        image = Vips::Image.thumbnail(input_path, TARGET_LIMIT, height: TARGET_LIMIT, size: :down)
        write_processed_file(image, output_path, quality: 90)
        { "processor" => "vips" }
      rescue LoadError, StandardError => error
        FileUtils.cp(input_path, output_path)
        {
          "processor" => "passthrough",
          "processor_error" => error.message
        }
      end

      def processed_metadata(path, processing_metadata:)
        dimensions = image_dimensions_for(path)

        {
          "content_type" => output_content_type,
          "width" => dimensions[:width],
          "height" => dimensions[:height],
          "processing_step" => "enhanced",
          "source_asset_id" => source_asset.id,
          "enhanced_at" => Time.current.iso8601,
          "enhancement_stack" => enhancement_stack_for(processing_metadata)
        }.compact.merge(processing_metadata)
      end

      def enhanced_basename
        "photo-enhanced-#{source_asset.id}"
      end

      def output_content_type
        source_asset.content_type.presence || source_asset.file.blob.content_type
      end

      def output_extension
        source_asset.file.filename.extension_with_delimiter.presence || ".png"
      end

      def image_dimensions_for(path)
        load_vips!
        image = Vips::Image.new_from_file(path, access: :sequential)
        { width: image.width, height: image.height }
      rescue LoadError, StandardError
        { width: source_asset.width, height: source_asset.height }.compact
      end

      def load_vips!
        require "vips" unless defined?(Vips::Image)
      end

      def enhancement_stack_for(processing_metadata)
        case processing_metadata["processor"]
        when "vips"
          [ "thumbnail" ]
        else
          []
        end
      end

      def write_processed_file(image, output_path, quality:)
        case output_extension.downcase
        when ".jpg", ".jpeg"
          image.write_to_file(output_path, Q: quality, strip: true)
        when ".webp"
          image.write_to_file(output_path, Q: quality)
        else
          image.write_to_file(output_path)
        end
      end

      def enhanced_filename
        "#{File.basename(source_asset.display_name, ".*")}-enhanced#{output_extension}"
      end
  end
end
