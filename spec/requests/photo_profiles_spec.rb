require 'rails_helper'

RSpec.describe 'PhotoProfiles', type: :request do
  let(:user) { create(:user) }
  let(:resume) { create(:resume, user: user) }

  before do
    sign_in_as(user)
  end

  describe 'POST /photo_profiles' do
    it 'creates a default photo profile, links the resume context, and redirects back with a localized notice' do
      return_to = edit_resume_path(resume, step: 'personal_details')

      expect do
        post photo_profiles_path, params: {
          resume_id: resume.id,
          return_to: return_to
        }
      end.to change(PhotoProfile, :count).by(1)

      photo_profile = user.photo_profiles.order(:created_at).last

      expect(response).to redirect_to(return_to)
      expect(flash[:notice]).to eq(I18n.t('resumes.photo_library.controller.profile_created'))
      expect(photo_profile.user).to eq(user)
      expect(photo_profile).to be_active
      expect(resume.reload.photo_profile).to eq(photo_profile)
    end

    it 'reuses the existing default profile instead of creating a duplicate' do
      existing_profile = PhotoProfile.create!(user: user, name: 'Pat Kumar Photo Library', status: :active)
      return_to = edit_resume_path(resume, step: 'personal_details')

      expect do
        post photo_profiles_path, params: {
          resume_id: resume.id,
          return_to: return_to
        }
      end.not_to change(PhotoProfile, :count)

      expect(response).to redirect_to(return_to)
      expect(flash[:notice]).to eq(I18n.t('resumes.photo_library.controller.profile_created'))
      expect(resume.reload.photo_profile).to eq(existing_profile)
    end
  end
end
