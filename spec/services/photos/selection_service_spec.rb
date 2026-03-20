require 'rails_helper'

RSpec.describe Photos::SelectionService, type: :service do
  def create_ready_photo_asset(photo_profile:, filename:, asset_kind: :enhanced)
    PhotoAsset.new(photo_profile:, asset_kind:, status: :ready).tap do |photo_asset|
      photo_asset.file.attach(io: StringIO.new('image-bytes'), filename:, content_type: 'image/png')
      photo_asset.save!
    end
  end

  let(:user) { create(:user) }
  let(:template) { create(:template) }
  let(:resume) { create(:resume, user:, template:, photo_profile: nil) }

  describe '#call' do
    it 'creates a template-scoped headshot selection and syncs the resume photo profile' do
      photo_profile = PhotoProfile.create!(user:, name: 'Pat Kumar Photo Library', status: :active)
      photo_asset = create_ready_photo_asset(photo_profile:, filename: 'headshot.png')

      result = described_class.new(resume:, photo_asset:).call

      expect(result.success?).to eq(true)
      expect(result.error_message).to be_nil
      expect(result.selection).to be_present
      expect(result.selection.resume).to eq(resume)
      expect(result.selection.template).to eq(template)
      expect(result.selection.photo_asset).to eq(photo_asset)
      expect(result.selection.slot_name).to eq('headshot')
      expect(result.selection.status).to eq('active')
      expect(resume.reload.photo_profile).to eq(photo_profile)
      expect(result.resume.selected_headshot_photo_asset).to eq(photo_asset)
    end

    it 'clears an existing selection when no photo asset is provided' do
      photo_profile = PhotoProfile.create!(user:, name: 'Pat Kumar Photo Library', status: :active)
      photo_asset = create_ready_photo_asset(photo_profile:, filename: 'headshot.png')
      resume.update!(photo_profile:)
      selection = ResumePhotoSelection.create!(
        resume:,
        template:,
        photo_asset: photo_asset,
        slot_name: 'headshot',
        status: :active
      )

      result = described_class.new(resume:, photo_asset: nil).call

      expect(result.success?).to eq(true)
      expect(result.selection).to be_nil
      expect { selection.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(resume.reload.resume_photo_selections).to be_empty
    end

    it 'rejects photo assets that belong to another user' do
      other_user = create(:user)
      other_profile = PhotoProfile.create!(user: other_user, name: 'Other User Photo Library', status: :active)
      photo_asset = create_ready_photo_asset(photo_profile: other_profile, filename: 'other-headshot.png')

      result = described_class.new(resume:, photo_asset: photo_asset).call

      expect(result.success?).to eq(false)
      expect(result.selection).to be_nil
      expect(result.error_message).to eq(I18n.t('resumes.photo_library.selection_service.asset_user_mismatch'))
      expect(resume.reload.photo_profile).to be_nil
      expect(resume.resume_photo_selections).to be_empty
    end
  end
end
