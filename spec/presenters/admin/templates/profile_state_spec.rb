require "rails_helper"

RSpec.describe Admin::Templates::ProfileState do
  let(:summary_builder) do
    lambda do |family_label:, entry_style:, sidebar_section_labels:, **|
      [ family_label, entry_style.to_s.titleize, sidebar_section_labels.presence&.to_sentence ].compact.join(" · ")
    end
  end

  describe "#layout_metadata" do
    it "builds normalized layout metadata and delegates summary composition" do
      template = build_stubbed(
        :template,
        active: true,
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: "sidebar-accent")
      )

      profile_state = described_class.new(template: template, summary_builder: summary_builder)

      expect(profile_state.layout_metadata).to include(
        family: "sidebar-accent",
        family_label: "Sidebar Accent",
        accent_color: "#4338CA",
        column_count: "two_column",
        column_count_label: "2 columns",
        density: "comfortable",
        density_label: "Comfortable",
        font_scale: "base",
        font_scale_label: "Base",
        theme_tone: "indigo",
        theme_tone_label: "Indigo",
        supports_headshot: false,
        header_style: "split",
        header_style_label: "Split",
        entry_style: "list",
        entry_style_label: "List",
        skill_style: "chips",
        skill_style_label: "Chips",
        section_heading_style: "rule",
        section_heading_style_label: "Rule",
        shell_style: "card",
        shell_style_label: "Card",
        sidebar_position: "left",
        sidebar_section_labels: [ "Skills", "Education" ],
        summary: "Sidebar Accent · List · Skills and Education",
        short_label: "SI"
      )
    end
  end

  describe "#layout_focus_summary" do
    it "describes the sidebar layout focus when sidebar sections are present" do
      template = build_stubbed(
        :template,
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: "editorial-split")
      )

      profile_state = described_class.new(template: template, summary_builder: summary_builder)

      expect(profile_state.layout_focus_summary).to eq("Left sidebar for Education, Skills, and Projects")
    end

    it "falls back to the balanced single-column summary when no sidebar sections exist" do
      template = build_stubbed(:template, layout_config: ResumeTemplates::Catalog.default_layout_config(family: "modern"))

      profile_state = described_class.new(template: template, summary_builder: summary_builder)

      expect(profile_state.layout_focus_summary).to eq("Balanced single-column section flow")
    end
  end

  describe "visibility state" do
    it "returns user-visible state for active templates" do
      template = build_stubbed(:template, active: true)
      profile_state = described_class.new(template: template, summary_builder: summary_builder)

      expect(profile_state.visibility_label).to eq("User-visible")
      expect(profile_state.visibility_description).to include("Signed-in users can choose this template")
      expect(profile_state.visibility_tone).to eq(:success)
    end

    it "returns admin-only state for inactive templates" do
      template = build_stubbed(:template, active: false)
      profile_state = described_class.new(template: template, summary_builder: summary_builder)

      expect(profile_state.visibility_label).to eq("Admin-only")
      expect(profile_state.visibility_description).to include("Inactive templates stay available for admin review")
      expect(profile_state.visibility_tone).to eq(:neutral)
    end
  end

  describe "headshot metadata state" do
    it "returns supported state when the renderer supports headshots" do
      template = build_stubbed(
        :template,
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: "editorial-split")
      )
      profile_state = described_class.new(template: template, summary_builder: summary_builder)

      expect(profile_state.headshot_metadata_label).to eq("Supported")
      expect(profile_state.headshot_metadata_description).to include("uploaded resume headshot")
      expect(profile_state.headshot_metadata_tone).to eq(:info)
    end

    it "returns fallback-only state when the renderer does not support headshots" do
      template = build_stubbed(:template)
      profile_state = described_class.new(template: template, summary_builder: summary_builder)

      expect(profile_state.headshot_metadata_label).to eq("Fallback only")
      expect(profile_state.headshot_metadata_description).to include("non-photo identity treatment")
      expect(profile_state.headshot_metadata_tone).to eq(:neutral)
    end
  end
end
