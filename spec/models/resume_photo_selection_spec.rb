require 'rails_helper'

RSpec.describe ResumePhotoSelection, type: :model do
  let(:user) { create(:user) }
  let(:resume) { create(:resume, user: user) }
  let(:photo_profile) { PhotoProfile.create!(user: user, name: 'Profile', status: :active) }
  let(:photo_asset) do
    PhotoAsset.new(photo_profile: photo_profile, asset_kind: :source, status: :ready).tap do |asset|
      asset.file.attach(io: StringIO.new('png'), filename: 'headshot.png', content_type: 'image/png')
      asset.save!
    end
  end

  def create_selection(slot_name: 'headshot', status: :active, **attrs)
    ResumePhotoSelection.create!(
      resume: resume,
      template: resume.template,
      photo_asset: photo_asset,
      slot_name: slot_name,
      status: status,
      **attrs
    )
  end

  describe 'validations' do
    it 'requires slot_name' do
      selection = ResumePhotoSelection.new(resume: resume, template: resume.template, photo_asset: photo_asset, slot_name: '')

      expect(selection).not_to be_valid
      expect(selection.errors[:slot_name]).to be_present
    end

    it 'rejects invalid slot_name values' do
      selection = ResumePhotoSelection.new(resume: resume, template: resume.template, photo_asset: photo_asset, slot_name: 'banner')

      expect(selection).not_to be_valid
      expect(selection.errors[:slot_name]).to include('is not included in the list')
    end

    it 'enforces unique slot_name per resume + template' do
      create_selection
      duplicate = ResumePhotoSelection.new(resume: resume, template: resume.template, photo_asset: photo_asset, slot_name: 'headshot')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:slot_name]).to include('has already been taken')
    end

    it 'rejects a photo_asset belonging to a different user' do
      other_user = create(:user)
      other_profile = PhotoProfile.create!(user: other_user, name: 'Other', status: :active)
      other_asset = PhotoAsset.new(photo_profile: other_profile, asset_kind: :source, status: :ready).tap do |a|
        a.file.attach(io: StringIO.new('png'), filename: 'other.png', content_type: 'image/png')
        a.save!
      end

      selection = ResumePhotoSelection.new(resume: resume, template: resume.template, photo_asset: other_asset, slot_name: 'headshot')

      expect(selection).not_to be_valid
      expect(selection.errors[:photo_asset]).to include('must belong to the same user as the resume')
    end
  end

  describe 'scopes' do
    it '.active returns only active selections' do
      active = create_selection(status: :active)
      other_template = create(:template)
      archived = ResumePhotoSelection.create!(
        resume: resume, template: other_template, photo_asset: photo_asset,
        slot_name: 'headshot', status: :archived
      )

      expect(ResumePhotoSelection.active).to include(active)
      expect(ResumePhotoSelection.active).not_to include(archived)
    end

    it '.for_slot filters by slot name' do
      headshot = create_selection(slot_name: 'headshot')

      expect(ResumePhotoSelection.for_slot('headshot')).to include(headshot)
    end
  end

  describe 'enums' do
    it 'supports active and archived statuses' do
      %w[active archived].each do |s|
        selection = create_selection(status: s)
        expect(selection.status).to eq(s)
        selection.destroy!
      end
    end
  end
end
