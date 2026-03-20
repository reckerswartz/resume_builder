module Photos
  class TempfileManager
    class << self
      def with_downloaded_attachment(attachment, basename: "photo-asset")
        extension = attachment.filename.extension_with_delimiter.presence || ".bin"

        with_tempfile(basename:, extension:) do |tempfile|
          tempfile.write(attachment.download)
          tempfile.rewind
          yield tempfile
        end
      end

      def with_tempfile(basename:, extension:)
        tempfile = Tempfile.new([ basename, extension.to_s.presence || ".bin" ])
        tempfile.binmode
        yield tempfile
      ensure
        tempfile&.close!
      end

      def with_decoded_base64(data, basename:, extension:)
        with_tempfile(basename:, extension:) do |tempfile|
          tempfile.write(Base64.decode64(data.to_s))
          tempfile.rewind
          yield tempfile
        end
      end
    end
  end
end
