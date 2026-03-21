require 'rails_helper'
require 'base64'

RSpec.describe Photos::TempfileManager, type: :service do
  describe '.with_tempfile' do
    it 'yields a tempfile with a .bin fallback and removes it after the block' do
      binary_bytes = "\x00\xFFtempfile-bytes".b
      path = nil
      observed = nil

      result = described_class.with_tempfile(basename: 'photo-tempfile', extension: nil) do |tempfile|
        path = tempfile.path
        expect(File.extname(path)).to eq('.bin')

        tempfile.write(binary_bytes)
        tempfile.rewind
        observed = tempfile.read

        :completed
      end

      expect(result).to eq(:completed)
      expect(observed).to eq(binary_bytes)
      expect(File.exist?(path)).to eq(false)
    end

    it 'removes the tempfile even when the block raises' do
      path = nil

      expect do
        described_class.with_tempfile(basename: 'photo-tempfile', extension: '.png') do |tempfile|
          path = tempfile.path
          raise 'tempfile failure'
        end
      end.to raise_error(RuntimeError, 'tempfile failure')

      expect(File.exist?(path)).to eq(false)
    end
  end

  describe '.with_downloaded_attachment' do
    it 'writes downloaded attachment bytes, rewinds, and removes the tempfile afterwards' do
      bytes = "\x89PNG\r\nattachment-bytes".b
      attachment = double(
        'ActiveStorage::AttachmentLike',
        filename: ActiveStorage::Filename.wrap('source.png'),
        download: bytes
      )
      path = nil
      observed = nil

      described_class.with_downloaded_attachment(attachment, basename: 'photo-source') do |tempfile|
        path = tempfile.path
        expect(File.extname(path)).to eq('.png')
        expect(tempfile.pos).to eq(0)

        observed = tempfile.read
      end

      expect(observed).to eq(bytes)
      expect(File.exist?(path)).to eq(false)
    end
  end

  describe '.with_decoded_base64' do
    it 'decodes base64 data, rewinds, and removes the tempfile afterwards' do
      bytes = 'generated-image-bytes'.b
      path = nil
      observed = nil

      described_class.with_decoded_base64(Base64.strict_encode64(bytes), basename: 'generated-photo', extension: '.webp') do |tempfile|
        path = tempfile.path
        expect(File.extname(path)).to eq('.webp')
        expect(tempfile.pos).to eq(0)

        observed = tempfile.read
      end

      expect(observed).to eq(bytes)
      expect(File.exist?(path)).to eq(false)
    end
  end
end
