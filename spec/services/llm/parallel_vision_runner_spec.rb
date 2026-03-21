require 'rails_helper'
require 'base64'

RSpec.describe Llm::ParallelVisionRunner do
  def create_source_photo_asset(photo_profile:, filename:, file_contents:)
    PhotoAsset.new(photo_profile:, asset_kind: :source, status: :ready).tap do |photo_asset|
      photo_asset.file.attach(io: StringIO.new(file_contents), filename:, content_type: 'image/png')
      photo_asset.save!
    end
  end

  let(:user) { create(:user) }
  let(:template) { create(:template) }
  let(:resume) { create(:resume, user:, template:) }
  let(:photo_profile) { create(:photo_profile, user:) }
  let(:first_source_asset) { create_source_photo_asset(photo_profile:, filename: 'source-headshot.png', file_contents: 'first-image-bytes') }
  let(:second_source_asset) { create_source_photo_asset(photo_profile:, filename: 'reference-headshot.png', file_contents: 'second-image-bytes') }
  let(:llm_provider) { create(:llm_provider) }
  let(:llm_model) { create(:llm_model, :vision_capable, llm_provider:, identifier: 'vision-model') }
  let(:feature_name) { 'resume_image_generation' }
  let(:prompt) { 'Generate polished resume headshot variations.' }
  let(:metadata) { { 'photo_profile_id' => photo_profile.id } }

  describe '#call' do
    it 'returns an empty array when no models are provided' do
      result = described_class.new(
        user:,
        resume:,
        feature_name:,
        role: 'vision_generation',
        prompt:,
        llm_models: [],
        source_assets: [ first_source_asset ],
        metadata:
      ).call

      expect(result).to eq([])
      expect(resume.llm_interactions).to be_empty
    end

    it 'calls the generation client, prepares images, and persists a successful interaction' do
      provider_client = instance_double('ProviderClient')
      captured_requests = []
      response = {
        content: 'Generated two polished variants',
        images: [
          {
            data: 'generated-image-data',
            content_type: 'image/png',
            provider_note: 'studio-light'
          },
          {
            'base64' => 'alternate-generated-image-data',
            'content_type' => 'image/webp'
          }
        ],
        token_usage: { 'input_tokens' => 18, 'output_tokens' => 24 },
        metadata: { 'provider_request_id' => 'req-vision-1' }
      }

      allow(Llm::ClientFactory).to receive(:build).with(llm_provider).and_return(provider_client)
      allow(provider_client).to receive(:generate_image_variations) do |model:, prompt:, images:|
        captured_requests << { model:, prompt:, images: }
        response
      end

      executions = described_class.new(
        user:,
        resume:,
        feature_name:,
        role: 'vision_generation',
        prompt:,
        llm_models: [ llm_model ],
        source_assets: [ first_source_asset, second_source_asset ],
        metadata:
      ).call

      expect(captured_requests).to eq([
        {
          model: llm_model,
          prompt: 'Generate polished resume headshot variations.',
          images: [
            {
              'data' => Base64.strict_encode64('first-image-bytes'),
              'content_type' => 'image/png',
              'filename' => 'source-headshot.png',
              'photo_asset_id' => first_source_asset.id
            },
            {
              'data' => Base64.strict_encode64('second-image-bytes'),
              'content_type' => 'image/png',
              'filename' => 'reference-headshot.png',
              'photo_asset_id' => second_source_asset.id
            }
          ]
        }
      ])

      expect(executions.size).to eq(1)

      execution = executions.first
      expect(execution).to be_success
      expect(execution.llm_model).to eq(llm_model)
      expect(execution.response_text).to eq('Generated two polished variants')
      expect(execution.images).to eq([
        {
          'data' => 'generated-image-data',
          'content_type' => 'image/png',
          'provider_note' => 'studio-light'
        },
        {
          'base64' => 'alternate-generated-image-data',
          'content_type' => 'image/webp'
        }
      ])
      expect(execution.token_usage).to eq({ 'input_tokens' => 18, 'output_tokens' => 24 })
      expect(execution.metadata).to eq({ 'provider_request_id' => 'req-vision-1' })
      expect(execution.error_message).to be_nil
      expect(execution.latency_ms).to be >= 0

      expect(execution.interaction).to have_attributes(
        user:,
        resume:,
        llm_model: llm_model,
        llm_provider:,
        feature_name:,
        role: 'vision_generation',
        status: 'succeeded',
        prompt:,
        response: 'Generated two polished variants',
        error_message: nil
      )
      expect(execution.interaction.token_usage).to eq({ 'input_tokens' => 18, 'output_tokens' => 24 })
      expect(execution.interaction.metadata).to include(
        'photo_profile_id' => photo_profile.id,
        'provider_request_id' => 'req-vision-1',
        'llm_provider_slug' => llm_provider.slug,
        'llm_model_identifier' => llm_model.identifier,
        'source_asset_ids' => [ first_source_asset.id, second_source_asset.id ],
        'generated_image_count' => 2
      )
    end

    it 'calls the verification client and skips interaction persistence when no resume is provided' do
      provider_client = instance_double('ProviderClient')
      captured_requests = []
      response = {
        content: 'Candidate looks professional and identity-consistent.',
        images: [],
        token_usage: { 'input_tokens' => 10, 'output_tokens' => 6 },
        metadata: { 'provider_request_id' => 'req-vision-verify' }
      }

      allow(Llm::ClientFactory).to receive(:build).with(llm_provider).and_return(provider_client)
      allow(provider_client).to receive(:verify_image_candidate) do |model:, prompt:, images:|
        captured_requests << { model:, prompt:, images: }
        response
      end

      execution = described_class.new(
        user:,
        resume: nil,
        feature_name: 'photo_candidate_verification',
        role: 'vision_verification',
        prompt: 'Review this generated headshot candidate.',
        llm_models: [ llm_model ],
        source_assets: [ first_source_asset ],
        metadata: { 'workflow_type' => 'verify_candidate' }
      ).call.first

      expect(captured_requests).to eq([
        {
          model: llm_model,
          prompt: 'Review this generated headshot candidate.',
          images: [
            {
              'data' => Base64.strict_encode64('first-image-bytes'),
              'content_type' => 'image/png',
              'filename' => 'source-headshot.png',
              'photo_asset_id' => first_source_asset.id
            }
          ]
        }
      ])

      expect(execution).to be_success
      expect(execution.response_text).to eq('Candidate looks professional and identity-consistent.')
      expect(execution.images).to eq([])
      expect(execution.token_usage).to eq({ 'input_tokens' => 10, 'output_tokens' => 6 })
      expect(execution.metadata).to eq({ 'provider_request_id' => 'req-vision-verify' })
      expect(execution.error_message).to be_nil
      expect(execution.interaction).to be_nil
      expect(LlmInteraction.count).to eq(0)
    end

    it 'captures provider failures in the execution and persisted interaction' do
      provider_client = instance_double('ProviderClient')

      allow(Llm::ClientFactory).to receive(:build).with(llm_provider).and_return(provider_client)
      allow(provider_client).to receive(:generate_image_variations)
        .with(model: llm_model, prompt:, images: kind_of(Array))
        .and_raise(StandardError, 'Vision provider unavailable')

      execution = described_class.new(
        user:,
        resume:,
        feature_name:,
        role: 'vision_generation',
        prompt:,
        llm_models: [ llm_model ],
        source_assets: [ first_source_asset ],
        metadata:
      ).call.first

      expect(execution).not_to be_success
      expect(execution.response_text).to be_nil
      expect(execution.images).to eq([])
      expect(execution.token_usage).to eq({})
      expect(execution.error_message).to eq('Vision provider unavailable')
      expect(execution.metadata).to eq({ 'exception_class' => 'StandardError' })
      expect(execution.latency_ms).to be >= 0

      expect(execution.interaction).to have_attributes(
        user:,
        resume:,
        llm_model: llm_model,
        llm_provider:,
        feature_name:,
        role: 'vision_generation',
        status: 'failed',
        prompt:,
        response: nil,
        error_message: 'Vision provider unavailable'
      )
      expect(execution.interaction.token_usage).to eq({})
      expect(execution.interaction.metadata).to include(
        'photo_profile_id' => photo_profile.id,
        'exception_class' => 'StandardError',
        'llm_provider_slug' => llm_provider.slug,
        'llm_model_identifier' => llm_model.identifier,
        'source_asset_ids' => [ first_source_asset.id ],
        'generated_image_count' => 0
      )
    end
  end
end
