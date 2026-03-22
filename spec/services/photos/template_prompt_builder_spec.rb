require 'rails_helper'

RSpec.describe Photos::TemplatePromptBuilder, type: :service do
  let(:source_asset) { double('source_asset') }

  describe '#call' do
    it 'builds prompt text from resume identity data and template headshot hints' do
      user = build(:user, email_address: 'pat@example.com')
      resume = build(
        :resume,
        user: user,
        template: build(:template),
        contact_details: { 'full_name' => 'Pat Kumar' },
        headline: 'Senior Product Designer'
      )
      template = instance_double(
        Template,
        normalized_layout_config: {
          'family' => 'editorial-split',
          'supports_headshot' => true,
          'photo_slots' => {
            'headshot' => {
              'portrait_shape' => 'circle',
              'crop_style' => 'contain',
              'background_style' => 'soft_gradient'
            }
          }
        }
      )

      prompt = described_class.new(resume: resume, template: template, source_asset: source_asset).call

      expect(prompt).to include('Resume name: Pat Kumar.')
      expect(prompt).to include('Headline: Senior Product Designer.')
      expect(prompt).to include('Template family: editorial-split.')
      expect(prompt).to include('Headshot supported: true.')
      expect(prompt).to include('Portrait shape hint: circle.')
      expect(prompt).to include('Crop style hint: contain.')
      expect(prompt).to include('Background style hint: soft_gradient.')
      expect(prompt).not_to include("\n")
    end

    it 'falls back to user display name, generic headline, and default slot hints when fields are missing' do
      user = build(:user, email_address: 'pat@example.com')
      resume = build(
        :resume,
        user: user,
        template: build(:template),
        contact_details: {},
        headline: ''
      )
      template = instance_double(
        Template,
        normalized_layout_config: {
          'family' => 'modern',
          'supports_headshot' => false,
          'photo_slots' => {}
        }
      )

      prompt = described_class.new(resume: resume, template: template, source_asset: source_asset).call

      expect(prompt).to include('Resume name: Pat.')
      expect(prompt).to include('Headline: Professional profile.')
      expect(prompt).to include('Template family: modern.')
      expect(prompt).to include('Headshot supported: false.')
      expect(prompt).to include('Portrait shape hint: rounded_square.')
      expect(prompt).to include('Crop style hint: cover.')
      expect(prompt).to include('Background style hint: studio_clean.')
    end
  end
end
