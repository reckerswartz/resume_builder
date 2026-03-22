require 'rails_helper'
require 'base64'

RSpec.describe 'PhotoAssets', type: :request do
  include ActiveJob::TestHelper

  TINY_PNG_BASE64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO2Z7mQAAAAASUVORK5CYII='

  let(:user) { create(:user) }
  let(:resume) { create(:resume, user: user) }
  let(:photo_profile) { PhotoProfile.create!(user: user, name: 'Primary Photo Library', status: :active) }

  before do
    sign_in_as(user)
    clear_enqueued_jobs
  end

  def uploaded_png(filename: 'headshot.png')
    Tempfile.create([ File.basename(filename, '.*'), File.extname(filename) ]) do |file|
      file.binmode
      file.write(Base64.decode64(TINY_PNG_BASE64))
      file.rewind
      yield Rack::Test::UploadedFile.new(file.path, 'image/png')
    end
  end

  def create_photo_asset(photo_profile:, filename:, asset_kind: :source, status: :ready, source_asset: nil)
    PhotoAsset.new(photo_profile:, asset_kind:, status:, source_asset:).tap do |photo_asset|
      photo_asset.file.attach(io: StringIO.new(Base64.decode64(TINY_PNG_BASE64)), filename:, content_type: 'image/png')
      photo_asset.save!
    end
  end

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

  def enable_vision_role(role)
    provider = create(:llm_provider)
    model = create(:llm_model, :vision_capable, llm_provider: provider)
    create(:llm_model_assignment, llm_model: model, role: role)
    model
  end

  describe 'POST /photo_profiles/:photo_profile_id/photo_assets' do
    it 'uploads a photo, links the resume context, and redirects back with the localized upload notice' do
      return_to = edit_resume_path(resume, step: 'personal_details')

      uploaded_png do |file|
        expect do
          post photo_profile_photo_assets_path(photo_profile), params: {
            resume_id: resume.id,
            return_to: return_to,
            photo_assets: {
              files: [ file ]
            }
          }
        end.to change(PhotoAsset, :count).by(1).and change(PhotoProcessingRun, :count).by(1)
      end

      expect(response).to redirect_to(return_to)
      expect(flash[:notice]).to eq(I18n.t('resumes.photo_library.controller.upload_started', count: 1))
      expect(resume.reload.photo_profile).to eq(photo_profile)

      created_asset = photo_profile.photo_assets.order(:created_at).last
      expect(created_asset).to be_source
      expect(created_asset).to be_uploaded
      expect(created_asset.file).to be_attached
    end

    it 'redirects back with the ingestion error when no files are attached' do
      return_to = edit_resume_path(resume, step: 'personal_details')

      expect do
        post photo_profile_photo_assets_path(photo_profile), params: {
          resume_id: resume.id,
          return_to: return_to,
          photo_assets: {
            files: []
          }
        }
      end.not_to change(PhotoAsset, :count)

      expect(response).to redirect_to(return_to)
      expect(flash[:alert]).to eq(I18n.t('resumes.photo_library.upload_ingestion_service.files_required'))
    end
  end

  describe 'DELETE /photo_profiles/:photo_profile_id/photo_assets/:id' do
    it 'deletes the selected source asset, promotes a replacement, and redirects with a localized notice' do
      return_to = edit_resume_path(resume, step: 'personal_details')
      selected_source_asset = create_photo_asset(photo_profile:, filename: 'selected-source.png')
      replacement_asset = create_photo_asset(photo_profile:, filename: 'replacement-source.png')
      photo_profile.update!(selected_source_photo_asset: selected_source_asset)

      expect do
        delete photo_profile_photo_asset_path(photo_profile, selected_source_asset), params: {
          resume_id: resume.id,
          return_to: return_to
        }
      end.to change(PhotoAsset, :count).by(-1)

      expect(response).to redirect_to(return_to)
      expect(flash[:notice]).to eq(I18n.t('resumes.photo_library.controller.photo_deleted'))
      expect(photo_profile.reload.selected_source_photo_asset).to eq(replacement_asset)
    end
  end

  describe 'POST /photo_profiles/:photo_profile_id/photo_assets/:id/background_remove' do
    it 'queues background removal for the asset when image generation is available' do
      return_to = edit_resume_path(resume, step: 'personal_details')
      photo_asset = create_photo_asset(photo_profile:, filename: 'background-source.png')
      enable_vision_role('vision_generation')

      with_feature_flags(llm_access: true, resume_image_generation: true) do
        expect do
          post background_remove_photo_profile_photo_asset_path(photo_profile, photo_asset), params: {
            resume_id: resume.id,
            return_to: return_to
          }
        end.to change(PhotoProcessingRun, :count).by(1)
      end

      expect(response).to redirect_to(return_to)
      expect(flash[:notice]).to eq(I18n.t('resumes.photo_library.controller.background_removal_started'))

      processing_run = photo_profile.photo_processing_runs.order(:created_at).last
      expect(processing_run.workflow_type).to eq('background_remove')
      expect(processing_run).to be_queued
      expect(processing_run.resume).to eq(resume)
      expect(processing_run.template).to eq(resume.template)
      expect(processing_run.input_asset_ids).to eq([ photo_asset.id ])
      expect(enqueued_jobs.map { |job| job[:job] }).to include(PhotoBackgroundRemovalJob)
    end
  end

  describe 'POST /photo_profiles/:photo_profile_id/photo_assets/:id/generate_for_template' do
    it 'queues template generation for the asset when image generation is available and a resume context is provided' do
      return_to = edit_resume_path(resume, step: 'personal_details')
      photo_asset = create_photo_asset(photo_profile:, filename: 'template-source.png')
      enable_vision_role('vision_generation')

      with_feature_flags(llm_access: true, resume_image_generation: true) do
        expect do
          post generate_for_template_photo_profile_photo_asset_path(photo_profile, photo_asset), params: {
            resume_id: resume.id,
            return_to: return_to
          }
        end.to change(PhotoProcessingRun, :count).by(1)
      end

      expect(response).to redirect_to(return_to)
      expect(flash[:notice]).to eq(I18n.t('resumes.photo_library.controller.generation_started'))

      processing_run = photo_profile.photo_processing_runs.order(:created_at).last
      expect(processing_run.workflow_type).to eq('generate_for_template')
      expect(processing_run).to be_queued
      expect(processing_run.resume).to eq(resume)
      expect(processing_run.template).to eq(resume.template)
      expect(processing_run.input_asset_ids).to eq([ photo_asset.id ])
      expect(enqueued_jobs.map { |job| job[:job] }).to include(ResumeTemplateImageGenerationJob)
    end
  end

  describe 'POST /photo_profiles/:photo_profile_id/photo_assets/:id/verify' do
    it 'queues verification for the asset when verification is available and a resume context is provided' do
      return_to = edit_resume_path(resume, step: 'personal_details')
      photo_asset = create_photo_asset(photo_profile:, filename: 'verify-source.png')
      enable_vision_role('vision_verification')

      with_feature_flags(llm_access: true, resume_image_generation: true) do
        expect do
          post verify_photo_profile_photo_asset_path(photo_profile, photo_asset), params: {
            resume_id: resume.id,
            return_to: return_to
          }
        end.to change(PhotoProcessingRun, :count).by(1)
      end

      expect(response).to redirect_to(return_to)
      expect(flash[:notice]).to eq(I18n.t('resumes.photo_library.controller.verification_started'))

      processing_run = photo_profile.photo_processing_runs.order(:created_at).last
      expect(processing_run.workflow_type).to eq('verify_candidate')
      expect(processing_run).to be_queued
      expect(processing_run.resume).to eq(resume)
      expect(processing_run.template).to eq(resume.template)
      expect(processing_run.input_asset_ids).to eq([ photo_asset.id ])
      expect(enqueued_jobs.map { |job| job[:job] }).to include(PhotoVerificationJob)
    end
  end
end
