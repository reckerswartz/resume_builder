require 'rails_helper'
require 'base64'

RSpec.describe Photos::EnhancementService, type: :service do
  def create_source_photo_asset(photo_profile:, filename: 'normalized-headshot.png', status: :ready, metadata: {})
    PhotoAsset.new(photo_profile:, asset_kind: :normalized, status:, metadata: metadata).tap do |photo_asset|
      photo_asset.file.attach(
        io: StringIO.new(Base64.decode64(tiny_png_base64)),
        filename:,
        content_type: 'image/png'
      )
      photo_asset.save!
    end
  end

  def tiny_png_base64
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO2Z7mQAAAAASUVORK5CYII='
  end

  def stub_vips_processing(width:, height:)
    vips_module = Module.new
    image_class = double('Vips::Image')
    vips_module.const_set(:Image, image_class)
    stub_const('Vips', vips_module)

    thumbnail_image = instance_double('Vips::ThumbnailImage')
    dimension_image = instance_double('Vips::DimensionImage', width:, height:)

    allow(Vips::Image).to receive(:thumbnail).and_return(thumbnail_image)
    allow(Vips::Image).to receive(:new_from_file).and_return(dimension_image)
    allow(thumbnail_image).to receive(:write_to_file) do |output_path, *|
      File.binwrite(output_path, Base64.decode64(tiny_png_base64))
    end
  end

  let(:user) { create(:user) }
  let(:photo_profile) { PhotoProfile.create!(user:, name: 'Pat Kumar Photo Library', status: :active) }

  describe '#call' do
    it 'creates an enhanced asset and records vips enhancement metadata when processing succeeds' do
      source_asset = create_source_photo_asset(photo_profile:, metadata: { 'width' => 320, 'height' => 240 })
      stub_vips_processing(width: 900, height: 1100)
      result = nil

      expect do
        result = described_class.new(source_asset:).call
      end.to change(PhotoAsset, :count).by(1)

      expect(result).to be_success
      expect(result.source_asset).to eq(source_asset)
      expect(result.asset).to be_persisted
      expect(result.asset).to be_enhanced
      expect(result.asset.source_asset).to eq(source_asset)
      expect(result.asset.file).to be_attached
      expect(result.metadata).to include(
        'processor' => 'vips',
        'processing_step' => 'enhanced',
        'source_asset_id' => source_asset.id,
        'width' => 900,
        'height' => 1100,
        'content_type' => 'image/png',
        'enhancement_stack' => [ 'thumbnail' ]
      )
      expect(result.metadata['enhanced_at']).to be_present
      expect(source_asset.reload).to be_ready
    end

    it 'falls back to a passthrough copy and empty enhancement stack when image processing is unavailable' do
      source_asset = create_source_photo_asset(photo_profile:, metadata: { 'width' => 640, 'height' => 480 })
      service = described_class.new(source_asset:)

      allow(service).to receive(:load_vips!).and_raise(LoadError, 'vips unavailable')

      result = service.call

      expect(result).to be_success
      expect(result.asset).to be_persisted
      expect(result.asset).to be_enhanced
      expect(result.asset.source_asset).to eq(source_asset)
      expect(result.asset.file).to be_attached
      expect(result.metadata).to include(
        'processor' => 'passthrough',
        'processing_step' => 'enhanced',
        'source_asset_id' => source_asset.id,
        'width' => 640,
        'height' => 480,
        'content_type' => 'image/png',
        'enhancement_stack' => []
      )
      expect(result.metadata['processor_error']).to include('vips unavailable')
      expect(source_asset.reload).to be_ready
    end

    it 'returns a failure result and leaves the source asset unchanged when enhanced asset persistence fails' do
      source_asset = create_source_photo_asset(photo_profile:)
      service = described_class.new(source_asset:)
      builder = instance_double(Photos::AssetBuilder)

      allow(service).to receive(:load_vips!).and_raise(LoadError, 'vips unavailable')
      allow(Photos::AssetBuilder).to receive(:new).and_return(builder)
      allow(builder).to receive(:call).and_raise(StandardError, 'asset build failed')

      result = service.call

      expect(result).not_to be_success
      expect(result.asset).to be_nil
      expect(result.metadata).to eq({})
      expect(result.error_message).to eq('asset build failed')
      expect(source_asset.reload).to be_ready
    end
  end
end
