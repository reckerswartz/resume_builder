require 'rails_helper'

RSpec.describe Photos::AssetBuilder, type: :service do
  def create_source_photo_asset(photo_profile:)
    PhotoAsset.new(
      photo_profile:,
      asset_kind: :source,
      status: :ready,
      metadata: { 'display_name' => 'source.png' }
    ).tap do |photo_asset|
      photo_asset.file.attach(
        io: StringIO.new('source image bytes'),
        filename: 'source.png',
        content_type: 'image/png'
      )
      photo_asset.save!
    end
  end

  let(:user) { create(:user) }
  let(:photo_profile) { PhotoProfile.create!(user:, name: 'Pat Kumar Photo Library', status: :active) }

  describe '#call' do
    it 'builds a derived asset and enriches metadata from the persisted attachment' do
      source_asset = create_source_photo_asset(photo_profile:)
      asset = described_class.new(
        photo_profile:,
        source_asset:,
        asset_kind: :enhanced,
        file_io: StringIO.new('enhanced image bytes'),
        filename: 'enhanced.png',
        content_type: 'image/png',
        metadata: {
          'processor' => 'vips',
          'checksum' => 'stale-checksum',
          'byte_size' => 0,
          'display_name' => 'stale-name.png'
        }
      ).call

      expect(asset).to be_persisted
      expect(asset.photo_profile).to eq(photo_profile)
      expect(asset.source_asset).to eq(source_asset)
      expect(asset).to be_enhanced
      expect(asset).to be_ready
      expect(asset.file).to be_attached

      asset.reload

      expect(asset.metadata).to include(
        'processor' => 'vips',
        'content_type' => 'image/png',
        'display_name' => 'enhanced.png'
      )
      expect(asset.metadata['byte_size']).to eq(asset.file.blob.byte_size)
      expect(asset.metadata['checksum']).to eq(asset.file.blob.checksum)
    end

    it 'rewinds the input io before attaching the derived asset' do
      source_asset = create_source_photo_asset(photo_profile:)
      original_bytes = 'rewound image bytes'
      file_io = StringIO.new(original_bytes)
      file_io.read

      asset = described_class.new(
        photo_profile:,
        source_asset:,
        asset_kind: :normalized,
        file_io:,
        filename: 'normalized.png',
        content_type: 'image/png'
      ).call

      expect(asset.file.blob.byte_size).to eq(original_bytes.bytesize)
      expect(asset.file.download).to eq(original_bytes)
    end

    it 'honors an explicit status override when building the asset' do
      source_asset = create_source_photo_asset(photo_profile:)

      asset = described_class.new(
        photo_profile:,
        source_asset:,
        asset_kind: :cutout,
        file_io: StringIO.new('cutout bytes'),
        filename: 'cutout.png',
        content_type: 'image/png',
        status: :uploaded
      ).call

      expect(asset).to be_uploaded
      expect(asset).to be_cutout
    end
  end
end
