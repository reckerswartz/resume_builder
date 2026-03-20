require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the Admin::TemplatesHelper. For example:
#
# describe Admin::TemplatesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe Admin::TemplatesHelper, type: :helper do
  describe '#template_headshot_metadata_label' do
    it 'returns Enabled when the internal headshot flag is on' do
      template = build_stubbed(:template, layout_config: ResumeTemplates::Catalog.default_layout_config.merge('supports_headshot' => true))

      expect(helper.template_headshot_metadata_label(template)).to eq('Enabled')
    end

    it 'returns Disabled when the internal headshot flag is off' do
      template = build_stubbed(:template)

      expect(helper.template_headshot_metadata_label(template)).to eq('Disabled')
    end
  end

  describe '#template_headshot_metadata_description' do
    it 'explains enabled headshot metadata as internal-only' do
      template = build_stubbed(:template, layout_config: ResumeTemplates::Catalog.default_layout_config.merge('supports_headshot' => true))

      expect(helper.template_headshot_metadata_description(template)).to include('Internal-only planning flag is on')
      expect(helper.template_headshot_metadata_description(template)).to include('do not advertise headshot support')
    end

    it 'explains disabled headshot metadata as internal-only' do
      template = build_stubbed(:template)

      expect(helper.template_headshot_metadata_description(template)).to include('Internal-only planning flag is off')
      expect(helper.template_headshot_metadata_description(template)).to include('omit headshot promises')
    end
  end

  describe '#template_headshot_metadata_tone' do
    it 'uses an informational tone when the internal headshot flag is on' do
      template = build_stubbed(:template, layout_config: ResumeTemplates::Catalog.default_layout_config.merge('supports_headshot' => true))

      expect(helper.template_headshot_metadata_tone(template)).to eq(:info)
    end

    it 'uses a neutral tone when the internal headshot flag is off' do
      template = build_stubbed(:template)

      expect(helper.template_headshot_metadata_tone(template)).to eq(:neutral)
    end
  end
end
