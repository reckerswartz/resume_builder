require 'rails_helper'
require 'base64'

RSpec.describe Photos::UploadIngestionService, type: :service do
  include ActiveJob::TestHelper

  TINY_PNG_BASE64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO2Z7mQAAAAASUVORK5CYII='

  let(:user) { create(:user) }
  let(:photo_profile) { PhotoProfile.create!(user:, name: 'Pat Kumar Photo Library', status: :active) }

  def with_uploaded_png(filename: 'headshot.png')
    Tempfile.create([ File.basename(filename, '.*'), File.extname(filename) ]) do |file|
      file.binmode
      file.write(Base64.decode64(TINY_PNG_BASE64))
      file.rewind
      yield Rack::Test::UploadedFile.new(file.path, 'image/png')
    end
  end

  before do
    clear_enqueued_jobs
  end

  describe '#call' do
    it 'creates a source asset and queues a normalization run' do
      result = nil

      expect do
        with_uploaded_png do |uploaded_file|
          result = described_class.new(
            user: user,
            photo_profile: photo_profile,
            uploaded_files: [ uploaded_file ]
          ).call
        end
      end.to change(PhotoAsset, :count).by(1).and change(PhotoProcessingRun, :count).by(1)

      expect(result).to be_success
      expect(result.created_assets.size).to eq(1)
      expect(result.duplicate_assets).to be_empty
      expect(result.errors).to be_empty

      created_asset = result.created_assets.first
      processing_run = photo_profile.photo_processing_runs.order(:created_at).last

      expect(created_asset).to be_uploaded
      expect(created_asset).to be_source
      expect(created_asset.file).to be_attached
      expect(processing_run).to be_queued
      expect(processing_run.workflow_type).to eq('normalize')
      expect(processing_run.input_asset_ids).to eq([ created_asset.id ])
      expect(enqueued_jobs.map { |job| job[:job] }).to include(PhotoNormalizeJob)
    end

    it 'skips duplicate uploads using checksum and byte size' do
      with_uploaded_png(filename: 'duplicate-headshot.png') do |uploaded_file|
        described_class.new(user: user, photo_profile: photo_profile, uploaded_files: [ uploaded_file ]).call
      end

      duplicate_result = nil

      expect do
        with_uploaded_png(filename: 'duplicate-headshot.png') do |uploaded_file|
          duplicate_result = described_class.new(
            user: user,
            photo_profile: photo_profile,
            uploaded_files: [ uploaded_file ]
          ).call
        end
      end.not_to change(PhotoAsset, :count)

      expect(duplicate_result).to be_success
      expect(duplicate_result.created_assets).to be_empty
      expect(duplicate_result.duplicate_assets.size).to eq(1)
      expect(duplicate_result.errors).to be_empty
    end
  end
end
