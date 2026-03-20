require "rails_helper"

RSpec.describe "db/seeds.rb" do
  let(:seed_file) { Rails.root.join("db/seeds.rb") }

  def load_seeds
    load seed_file.to_s
  end

  it "seeds a demo resume with photo library headshot data" do
    load_seeds

    expect(PlatformSetting.current.feature_enabled?("photo_processing")).to eq(true)
    expect(PlatformSetting.current.feature_enabled?("resume_image_generation")).to eq(false)

    user = User.find_by!(email_address: "demo-with-photo@resume-builder.local")
    resume = user.resumes.find_by!(template: Template.find_by!(slug: "editorial-split"))
    photo_profile = resume.photo_profile

    expect(photo_profile).to be_present
    expect(photo_profile.user).to eq(user)
    expect(photo_profile).to be_active

    source_asset = photo_profile.selected_source_photo_asset
    expect(source_asset).to be_present
    expect(source_asset).to be_source
    expect(source_asset.file).to be_attached

    selection = resume.resume_photo_selections.find_by!(template: resume.template, slot_name: "headshot")
    expect(selection).to be_active
    expect(selection.photo_asset).to eq(photo_profile.photo_assets.find_by!(asset_kind: "enhanced"))
    expect(selection.photo_asset.file).to be_attached
  end

  it "keeps the seeded photo library records idempotent" do
    load_seeds

    baseline_counts = {
      users: User.count,
      resumes: Resume.count,
      photo_profiles: PhotoProfile.count,
      photo_assets: PhotoAsset.count,
      resume_photo_selections: ResumePhotoSelection.count
    }

    load_seeds

    expect(
      users: User.count,
      resumes: Resume.count,
      photo_profiles: PhotoProfile.count,
      photo_assets: PhotoAsset.count,
      resume_photo_selections: ResumePhotoSelection.count
    ).to eq(baseline_counts)
  end
end
