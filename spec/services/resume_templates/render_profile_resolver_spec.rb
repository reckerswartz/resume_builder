require "rails_helper"

RSpec.describe ResumeTemplates::RenderProfileResolver do
  describe "#call" do
    it "returns the template layout config when no render-ready implementation exists" do
      template = create(
        :template,
        slug: "modern",
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: "modern")
      )
      create(:template_implementation, template: template, status: "draft", renderer_family: "classic", render_profile: { "family" => "classic" })

      resolved = described_class.new(template: template).call

      expect(resolved).to include("family" => "modern")
    end

    it "prefers the most recent render-ready implementation profile" do
      template = create(
        :template,
        slug: "modern",
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: "modern")
      )
      create(
        :template_implementation,
        template: template,
        status: "validated",
        renderer_family: "classic",
        render_profile: {
          "family" => "classic",
          "accent_color" => "#1d4ed8",
          "density" => "compact"
        }
      )

      resolved = described_class.new(template: template).call

      expect(resolved).to include(
        "family" => "classic",
        "accent_color" => "#1d4ed8",
        "density" => "compact"
      )
    end
  end
end
