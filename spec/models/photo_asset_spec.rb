require 'rails_helper'

RSpec.describe PhotoAsset, type: :model do
  let(:user) { create(:user) }
  let(:photo_profile) { PhotoProfile.create!(user: user, name: 'Test Profile', status: :active) }

  def create_asset(profile: photo_profile, asset_kind: :source, status: :ready, source_asset: nil, filename: 'test.png')
    PhotoAsset.new(photo_profile: profile, asset_kind: asset_kind, status: status, source_asset: source_asset).tap do |asset|
      asset.file.attach(io: StringIO.new('fake png data'), filename: filename, content_type: 'image/png')
      asset.save!
    end
  end

  describe 'validations' do
    it 'requires asset_kind and status' do
      asset = PhotoAsset.new(photo_profile: photo_profile)
      asset.file.attach(io: StringIO.new('data'), filename: 'test.png', content_type: 'image/png')
      asset.asset_kind = nil
      asset.status = nil

      expect(asset).not_to be_valid
      expect(asset.errors[:asset_kind]).to be_present
      expect(asset.errors[:status]).to be_present
    end

    it 'requires a file attachment' do
      asset = PhotoAsset.new(photo_profile: photo_profile, asset_kind: :source, status: :ready)

      expect(asset).not_to be_valid
      expect(asset.errors[:file]).to include('must be attached')
    end

    it 'rejects non-image content types' do
      asset = PhotoAsset.new(photo_profile: photo_profile, asset_kind: :source, status: :ready)
      asset.file.attach(io: StringIO.new('not an image'), filename: 'test.pdf', content_type: 'application/pdf')

      expect(asset).not_to be_valid
      expect(asset.errors[:file]).to include('must be a JPG, PNG, or WebP image')
    end

    it 'rejects source assets from a different profile' do
      other_profile = PhotoProfile.create!(user: user, name: 'Other', status: :active)
      source = create_asset(profile: other_profile)

      asset = PhotoAsset.new(photo_profile: photo_profile, asset_kind: :cutout, status: :ready, source_asset: source)
      asset.file.attach(io: StringIO.new('data'), filename: 'cutout.png', content_type: 'image/png')

      expect(asset).not_to be_valid
      expect(asset.errors[:source_asset]).to include('must belong to the same photo profile')
    end

    it 'accepts source assets from the same profile' do
      source = create_asset
      asset = PhotoAsset.new(photo_profile: photo_profile, asset_kind: :enhanced, status: :ready, source_asset: source)
      asset.file.attach(io: StringIO.new('data'), filename: 'enhanced.png', content_type: 'image/png')

      expect(asset).to be_valid
    end
  end

  describe 'enums' do
    it 'supports all asset_kind values' do
      %w[source normalized cutout enhanced generated variation template_composite rejected].each do |kind|
        asset = build(:photo_asset_minimal, photo_profile: photo_profile, asset_kind: kind)
        expect(asset.asset_kind).to eq(kind)
      end
    end

    it 'supports all status values' do
      %w[uploaded ready archived failed].each do |s|
        asset = build(:photo_asset_minimal, photo_profile: photo_profile, status: s)
        expect(asset.status).to eq(s)
      end
    end
  end

  describe 'scopes' do
    it '.ready_for_library returns ready assets with valid selection kinds' do
      ready_source = create_asset(status: :ready, asset_kind: :source)
      ready_enhanced = create_asset(status: :ready, asset_kind: :enhanced, source_asset: ready_source)
      create_asset(status: :archived, asset_kind: :source, filename: 'archived.png')

      expect(PhotoAsset.ready_for_library).to include(ready_source, ready_enhanced)
      expect(PhotoAsset.ready_for_library).not_to include(PhotoAsset.where(status: 'archived').first)
    end

    it '.latest_first orders by most recent first' do
      old_asset = create_asset(filename: 'old.png')
      old_asset.update_column(:updated_at, 1.day.ago)
      new_asset = create_asset(filename: 'new.png')

      expect(PhotoAsset.latest_first.first).to eq(new_asset)
    end
  end

  describe '#ready_for_selection?' do
    it 'returns true for ready non-rejected assets' do
      asset = create_asset(status: :ready, asset_kind: :enhanced)

      expect(asset.ready_for_selection?).to be(true)
    end

    it 'returns false for rejected assets' do
      asset = create_asset(status: :ready, asset_kind: :rejected)

      expect(asset.ready_for_selection?).to be(false)
    end

    it 'returns false for non-ready assets' do
      asset = create_asset(status: :uploaded, asset_kind: :source)

      expect(asset.ready_for_selection?).to be(false)
    end
  end

  describe '#selection_priority' do
    it 'ranks enhanced higher than source' do
      enhanced = build(:photo_asset_minimal, asset_kind: :enhanced)
      source = build(:photo_asset_minimal, asset_kind: :source)

      expect(enhanced.selection_priority).to be < source.selection_priority
    end
  end

  describe '#display_name' do
    it 'returns metadata display_name when present' do
      asset = create_asset
      asset.attach_metadata!('display_name' => 'My Headshot')

      expect(asset.display_name).to eq('My Headshot')
    end

    it 'falls back to filename' do
      asset = create_asset(filename: 'headshot.png')

      expect(asset.display_name).to eq('headshot.png')
    end
  end

  describe '#attach_metadata!' do
    it 'merges new metadata into existing metadata' do
      asset = create_asset
      asset.attach_metadata!('width' => 200, 'height' => 200)

      expect(asset.reload.metadata).to include('width' => 200, 'height' => 200)
    end
  end

  describe 'normalization' do
    it 'deep-stringifies metadata on save' do
      asset = create_asset
      asset.update!(metadata: { seeded: true, dimensions: { w: 100 } })

      expect(asset.metadata.keys).to all(be_a(String))
    end
  end
end
