require "rails_helper"

RSpec.describe TemplateImplementation, type: :model do
  let(:template) { create(:template, slug: "modern") }

  describe "callbacks" do
    it "normalizes payloads, assigns renderer_family, and builds a stable identifier" do
      implementation = described_class.create!(
        template: template,
        identifier: "",
        name: "Modern shipped profile",
        status: "validated",
        render_profile: {
          family: "classic",
          accent_color: "#abc",
          density: "compact"
        },
        metadata: { source: "seed" }
      )

      expect(implementation.renderer_family).to eq("classic")
      expect(implementation.identifier).to eq("modern-classic-modern-shipped-profile")
      expect(implementation.render_profile).to include("family" => "classic", "accent_color" => "#abc")
      expect(implementation.metadata).to include("source" => "seed")
      expect(implementation.effective_render_profile).to include(
        "family" => "classic",
        "accent_color" => "#aabbcc",
        "density" => "compact"
      )
    end
  end

  describe "scopes" do
    it ".render_ready includes only validated, stable, and seeded implementations" do
      validated = create(:template_implementation, template: template, status: "validated")
      stable = create(:template_implementation, template: template, status: "stable")
      seeded = create(:template_implementation, template: template, status: "seeded")
      draft = create(:template_implementation, template: template, status: "draft")

      expect(described_class.render_ready).to include(validated, stable, seeded)
      expect(described_class.render_ready).not_to include(draft)
    end
  end

  describe "#seed_ready?" do
    it "returns true for stable implementations" do
      implementation = build(:template_implementation, template: template, status: "stable")
      expect(implementation.seed_ready?).to eq(true)
    end

    it "returns false for validated implementations" do
      implementation = build(:template_implementation, template: template, status: "validated")
      expect(implementation.seed_ready?).to eq(false)
    end
  end
end
