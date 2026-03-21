require "rails_helper"

RSpec.describe TemplateValidationRun, type: :model do
  let(:template) { create(:template, slug: "modern") }

  describe "callbacks" do
    it "normalizes payloads and assigns an identifier" do
      run = described_class.create!(
        template: template,
        identifier: "",
        validation_type: "pdf_export",
        status: "passed",
        metrics: { page_count: 2 },
        metadata: { source: "seed" },
        validator_name: "RSpec"
      )

      expect(run.identifier).to include("modern-pdf-export")
      expect(run.metrics).to include("page_count" => 2)
      expect(run.metadata).to include("source" => "seed")
      expect(run.successful?).to eq(true)
    end
  end

  describe "scopes" do
    it ".successful returns only passed runs" do
      passed = create(:template_validation_run, template: template, status: "passed")
      failed = create(:template_validation_run, template: template, status: "failed")

      expect(described_class.successful).to include(passed)
      expect(described_class.successful).not_to include(failed)
    end
  end
end
