require "rails_helper"

RSpec.describe Resumes::DraftBuilder do
  describe "#call" do
    let(:user) { create(:user, email_address: "alex@example.com") }
    let(:template) { create(:template, name: "Modern", slug: "modern") }

    it "builds an unsaved draft with setup defaults" do
      draft = described_class.new(
        user: user,
        template: template,
        attributes: {
          intake_details: {
            experience_level: "less_than_3_years"
          }
        }
      ).call

      draft.valid?

      expect(draft).to be_new_record
      expect(draft.title).to eq("Untitled Resume")
      expect(draft.template).to eq(template)
      expect(draft.source_mode).to eq("scratch")
      expect(draft.source_text).to eq("")
      expect(draft.contact_details).to include(
        "full_name" => user.display_name,
        "email" => user.email_address
      )
      expect(draft.intake_details).to eq(
        "experience_level" => "less_than_3_years",
        "student_status" => ""
      )
      expect(draft.personal_details).to eq(
        "date_of_birth" => "",
        "nationality" => "",
        "marital_status" => "",
        "visa_status" => ""
      )
      expect(draft.settings).to eq(
        "accent_color" => "#0F172A",
        "show_contact_icons" => true,
        "page_size" => "A4"
      )
    end

    it "preserves provided draft attributes while keeping default fallbacks" do
      draft = described_class.new(
        user: user,
        template: template,
        attributes: {
          title: "",
          headline: "Senior Product Engineer",
          summary: "Builds product systems",
          source_mode: "paste",
          source_text: "Imported source text",
          intake_details: {
            experience_level: "three_to_five_years"
          },
          personal_details: {
            nationality: "Indian"
          }
        }
      ).call

      draft.valid?

      expect(draft.title).to eq("Untitled Resume")
      expect(draft.headline).to eq("Senior Product Engineer")
      expect(draft.summary).to eq("Builds product systems")
      expect(draft.source_mode).to eq("paste")
      expect(draft.source_text).to eq("Imported source text")
      expect(draft.intake_details).to eq(
        "experience_level" => "three_to_five_years",
        "student_status" => ""
      )
      expect(draft.personal_details).to eq(
        "date_of_birth" => "",
        "nationality" => "Indian",
        "marital_status" => "",
        "visa_status" => ""
      )
    end
  end
end
