require "rails_helper"

RSpec.describe TemplateArtifact, type: :model do
  let(:template) { create(:template) }

  describe "validations" do
    it "requires name" do
      artifact = template.template_artifacts.new(artifact_type: "design_note", name: "")
      expect(artifact).not_to be_valid
      expect(artifact.errors[:name]).to include("can't be blank")
    end

    it "requires artifact_type" do
      artifact = template.template_artifacts.new(artifact_type: "", name: "Test")
      expect(artifact).not_to be_valid
      expect(artifact.errors[:artifact_type]).to be_present
    end

    it "rejects unknown artifact_type" do
      artifact = template.template_artifacts.new(artifact_type: "unknown", name: "Test")
      expect(artifact).not_to be_valid
      expect(artifact.errors[:artifact_type]).to include("is not included in the list")
    end

    it "rejects unknown status" do
      artifact = template.template_artifacts.new(artifact_type: "design_note", name: "Test", status: "bogus")
      expect(artifact).not_to be_valid
      expect(artifact.errors[:status]).to include("is not included in the list")
    end

    it "accepts all valid artifact types" do
      TemplateArtifact::ARTIFACT_TYPES.each do |type|
        artifact = template.template_artifacts.new(artifact_type: type, name: "#{type} test")
        expect(artifact).to be_valid, "Expected artifact_type '#{type}' to be valid"
      end
    end

    it "assigns identifier, source signature, and lineage automatically" do
      artifact = template.template_artifacts.create!(
        artifact_type: "reference_design",
        name: "Behance capture",
        metadata: { "reference_source_url" => "https://behance.net/example" }
      )

      expect(artifact.identifier).to start_with("#{template.slug}-reference-design")
      expect(artifact.source_signature).to be_present
      expect(artifact.reference_source_url).to eq("https://behance.net/example")
      expect(artifact).to be_source
      expect(artifact.immutable_source).to eq(true)
    end
  end

  describe "scopes" do
    it ".active returns only active artifacts" do
      active = template.template_artifacts.create!(artifact_type: "design_note", name: "Active", status: "active")
      archived = template.template_artifacts.create!(artifact_type: "design_note", name: "Archived", status: "archived")

      expect(TemplateArtifact.active).to include(active)
      expect(TemplateArtifact.active).not_to include(archived)
    end

    it ".by_type filters by artifact type" do
      note = template.template_artifacts.create!(artifact_type: "design_note", name: "Note")
      report = template.template_artifacts.create!(artifact_type: "discrepancy_report", name: "Report")

      expect(TemplateArtifact.by_type("design_note")).to include(note)
      expect(TemplateArtifact.by_type("design_note")).not_to include(report)
    end

    it ".discrepancy_reports returns only discrepancy_report type" do
      report = template.template_artifacts.create!(artifact_type: "discrepancy_report", name: "Report")
      note = template.template_artifacts.create!(artifact_type: "design_note", name: "Note")

      expect(TemplateArtifact.discrepancy_reports).to include(report)
      expect(TemplateArtifact.discrepancy_reports).not_to include(note)
    end

    it ".immutable_sources returns only immutable source artifacts" do
      source = template.template_artifacts.create!(artifact_type: "reference_design", name: "Source")
      derived = template.template_artifacts.create!(artifact_type: "version_snapshot", name: "Derived")

      expect(TemplateArtifact.immutable_sources).to include(source)
      expect(TemplateArtifact.immutable_sources).not_to include(derived)
    end
  end

  describe "#discrepancy_items" do
    it "returns discrepancies from metadata" do
      items = [ { "id" => "TEST-001", "area" => "header", "severity" => "minor", "status" => "open" } ]
      artifact = template.template_artifacts.create!(
        artifact_type: "discrepancy_report",
        name: "Test Report",
        metadata: { "discrepancies" => items }
      )
      expect(artifact.discrepancy_items).to eq(items)
    end

    it "returns empty array when no discrepancies in metadata" do
      artifact = template.template_artifacts.create!(
        artifact_type: "discrepancy_report",
        name: "Empty Report",
        metadata: {}
      )
      expect(artifact.discrepancy_items).to eq([])
    end
  end

  describe "#pixel_status" do
    it "returns pixel_status from metadata" do
      artifact = template.template_artifacts.create!(
        artifact_type: "reference_design",
        name: "Ref",
        metadata: { "pixel_status" => "close" }
      )
      expect(artifact.pixel_status).to eq("close")
    end

    it "defaults to not_started" do
      artifact = template.template_artifacts.create!(
        artifact_type: "reference_design",
        name: "New Ref",
        metadata: {}
      )
      expect(artifact.pixel_status).to eq("not_started")
    end
  end

  describe "#primary_attachment" do
    it "prefers artifact_file when attached" do
      artifact = template.template_artifacts.create!(artifact_type: "design_note", name: "Attachment")
      artifact.artifact_file.attach(io: StringIO.new("payload"), filename: "artifact.txt", content_type: "text/plain")

      expect(artifact.primary_attachment).to eq(artifact.artifact_file)
    end

    it "falls back to reference_image when artifact_file is absent" do
      artifact = template.template_artifacts.create!(artifact_type: "reference_image", name: "Reference image")
      artifact.reference_image.attach(io: StringIO.new("image"), filename: "reference.png", content_type: "image/png")

      expect(artifact.primary_attachment).to eq(artifact.reference_image)
    end
  end

  describe "association" do
    it "belongs to a template" do
      artifact = template.template_artifacts.create!(artifact_type: "design_note", name: "Note")
      expect(artifact.template).to eq(template)
    end

    it "is destroyed when template is destroyed" do
      new_template = Template.create!(name: "Temp", slug: "temp-test", layout_config: { "family" => "modern" })
      new_template.template_artifacts.create!(artifact_type: "design_note", name: "Note")
      expect { new_template.destroy! }.to change(TemplateArtifact, :count).by(-1)
    end
  end
end
