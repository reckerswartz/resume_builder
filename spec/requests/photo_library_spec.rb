require 'rails_helper'
require 'base64'

RSpec.describe 'Photo library', type: :request do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:resume) { create(:resume, user:) }
  let(:photo_profile) { PhotoProfile.create!(user:, name: 'Pat Kumar Photo Library', status: :active) }
  let(:return_to_path) { edit_resume_path(resume, step: 'personal_details') }

  def with_feature_flags(overrides)
    platform_setting = PlatformSetting.current
    original_feature_flags = platform_setting.feature_flags.deep_dup

    platform_setting.update!(
      feature_flags: original_feature_flags.merge(overrides.transform_keys(&:to_s)),
      preferences: platform_setting.preferences
    )

    yield
  ensure
    platform_setting.update!(feature_flags: original_feature_flags, preferences: platform_setting.preferences) if defined?(original_feature_flags)
  end

  def with_uploaded_png(filename: 'headshot.png')
    Tempfile.create([ File.basename(filename, '.*'), File.extname(filename) ]) do |file|
      file.binmode
      file.write(Base64.decode64(tiny_png_base64))
      file.rewind
      yield Rack::Test::UploadedFile.new(file.path, 'image/png')
    end
  end

  def tiny_png_base64
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO2Z7mQAAAAASUVORK5CYII='
  end

  def create_ready_photo_asset(photo_profile:, filename:, asset_kind: :enhanced)
    PhotoAsset.new(photo_profile:, asset_kind:, status: :ready).tap do |photo_asset|
      photo_asset.file.attach(io: StringIO.new('image-bytes'), filename:, content_type: 'image/png')
      photo_asset.save!
    end
  end

  before do
    clear_enqueued_jobs
    sign_in_as(user)
  end

  describe 'POST /photo_profiles' do
    it 'creates a default photo profile for the resume context and uses the localized notice' do
      expect do
        post photo_profiles_path, params: {
          resume_id: resume.id,
          return_to: return_to_path
        }
      end.to change(PhotoProfile, :count).by(1)

      expect(response).to redirect_to(return_to_path)
      expect(flash[:notice]).to eq(I18n.t('resumes.photo_library.controller.profile_created'))
      expect(user.photo_profiles.order(:created_at).last).to be_present
      expect(resume.reload.photo_profile).to eq(user.photo_profiles.order(:created_at).last)
    end
  end

  describe 'POST /photo_profiles/:photo_profile_id/photo_assets' do
    it 'uses the localized upload validation alert when no files are attached' do
      post photo_profile_photo_assets_path(photo_profile), params: {
        resume_id: resume.id,
        return_to: return_to_path,
        photo_assets: {
          files: []
        }
      }

      expect(response).to redirect_to(return_to_path)
      expect(flash[:alert]).to eq(I18n.t('resumes.photo_library.upload_ingestion_service.files_required'))
    end

    it 'creates a source asset, queues normalization, links the resume profile, and uses the localized upload notice' do
      expect do
        with_uploaded_png do |uploaded_file|
          post photo_profile_photo_assets_path(photo_profile), params: {
            resume_id: resume.id,
            return_to: return_to_path,
            photo_assets: {
              files: [ uploaded_file ]
            }
          }
        end
      end.to change(PhotoAsset, :count).by(1).and change(PhotoProcessingRun, :count).by(1)

      expect(response).to redirect_to(return_to_path)
      expect(flash[:notice]).to eq(I18n.t('resumes.photo_library.controller.upload_started', count: 1))
      expect(resume.reload.photo_profile).to eq(photo_profile)
      expect(enqueued_jobs.map { |job| job[:job] }).to include(PhotoNormalizeJob)
    end
  end

  describe 'DELETE /photo_profiles/:photo_profile_id/photo_assets/:id' do
    it 'deletes the asset and uses the localized notice' do
      photo_asset = create_ready_photo_asset(photo_profile:, filename: 'selected-headshot.png')

      expect do
        delete photo_profile_photo_asset_path(photo_profile, photo_asset), params: {
          resume_id: resume.id,
          return_to: return_to_path
        }
      end.to change(PhotoAsset, :count).by(-1)

      expect(response).to redirect_to(return_to_path)
      expect(flash[:notice]).to eq(I18n.t('resumes.photo_library.controller.photo_deleted'))
    end
  end

  describe 'POST /photo_profiles/:photo_profile_id/photo_assets/:id/background_remove' do
    it 'uses the localized unavailable alert when image generation is disabled' do
      photo_asset = create_ready_photo_asset(photo_profile:, filename: 'selected-headshot.png')

      post background_remove_photo_profile_photo_asset_path(photo_profile, photo_asset), params: {
        resume_id: resume.id,
        return_to: return_to_path
      }

      expect(response).to redirect_to(return_to_path)
      expect(flash[:alert]).to eq(I18n.t('resumes.photo_library.controller.generation_unavailable'))
    end
  end

  describe 'POST /photo_profiles/:photo_profile_id/photo_assets/:id/generate_for_template' do
    let(:llm_provider) { create(:llm_provider) }
    let(:llm_model) { create(:llm_model, :vision_capable, llm_provider:) }

    before do
      create(:llm_model_assignment, llm_model:, role: 'vision_generation')
    end

    it 'queues template generation and uses the localized notice' do
      photo_asset = create_ready_photo_asset(photo_profile:, filename: 'selected-headshot.png')

      with_feature_flags(photo_processing: true, llm_access: true, resume_image_generation: true) do
        expect do
          post generate_for_template_photo_profile_photo_asset_path(photo_profile, photo_asset), params: {
            resume_id: resume.id,
            return_to: return_to_path
          }
        end.to change(PhotoProcessingRun, :count).by(1)
      end

      expect(response).to redirect_to(return_to_path)
      expect(flash[:notice]).to eq(I18n.t('resumes.photo_library.controller.generation_started'))

      processing_run = photo_profile.photo_processing_runs.order(:created_at).last
      expect(processing_run.workflow_type).to eq('generate_for_template')
      expect(processing_run.resume).to eq(resume)
      expect(processing_run.template).to eq(resume.template)
      expect(enqueued_jobs.map { |job| job[:job] }).to include(ResumeTemplateImageGenerationJob)
    end
  end
end
