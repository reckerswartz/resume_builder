require "rails_helper"

RSpec.describe Resumes::Duplicator do
  let(:user) { create(:user) }
  let(:template) { create(:template) }
  let(:resume) do
    create(:resume, user:, template:,
      title: "Senior Engineer Resume",
      headline: "Staff Software Engineer",
      summary: "Experienced engineer with 10+ years building distributed systems.",
      source_mode: "paste",
      source_text: "Original pasted content",
      contact_details: { "full_name" => "Jane Doe", "email" => "jane@example.com", "phone" => "+1-555-0100" },
      personal_details: { "nationality" => "US", "date_of_birth" => "", "marital_status" => "", "visa_status" => "" },
      intake_details: { "experience_level" => "ten_plus_years" },
      settings: { "accent_color" => "#4338CA", "page_size" => "A4", "show_contact_icons" => true }
    )
  end

  before do
    experience = resume.sections.create!(title: "Experience", section_type: "experience", position: 0, settings: {})
    experience.entries.create!(content: { "title" => "Staff Engineer", "company" => "Acme Corp", "highlights" => ["Led platform team"] }, position: 0)
    experience.entries.create!(content: { "title" => "Senior Engineer", "company" => "StartupCo", "highlights" => ["Built API layer"] }, position: 1)

    skills = resume.sections.create!(title: "Skills", section_type: "skills", position: 1, settings: {})
    skills.entries.create!(content: { "name" => "Ruby", "level" => "expert" }, position: 0)
  end

  subject(:copy) { described_class.new(resume: resume).call }

  it "creates a new resume with 'Copy of' title prefix" do
    expect(copy).to be_persisted
    expect(copy.title).to eq("Copy of Senior Engineer Resume")
    expect(copy.id).not_to eq(resume.id)
  end

  it "copies content fields without source document references" do
    expect(copy.headline).to eq("Staff Software Engineer")
    expect(copy.summary).to eq("Experienced engineer with 10+ years building distributed systems.")
    expect(copy.source_mode).to eq("scratch")
    expect(copy.source_text).to eq("")
  end

  it "copies contact details, personal details, intake details, and settings" do
    expect(copy.contact_details["full_name"]).to eq("Jane Doe")
    expect(copy.contact_details["email"]).to eq("jane@example.com")
    expect(copy.personal_details["nationality"]).to eq("US")
    expect(copy.intake_details["experience_level"]).to eq("ten_plus_years")
    expect(copy.settings["accent_color"]).to eq("#4338CA")
  end

  it "preserves the template and user associations" do
    expect(copy.template).to eq(template)
    expect(copy.user).to eq(user)
  end

  it "deep-copies sections with preserved positions" do
    expect(copy.sections.size).to eq(2)

    experience_copy = copy.sections.find_by(section_type: "experience")
    skills_copy = copy.sections.find_by(section_type: "skills")

    expect(experience_copy.title).to eq("Experience")
    expect(experience_copy.position).to eq(0)
    expect(skills_copy.title).to eq("Skills")
    expect(skills_copy.position).to eq(1)
  end

  it "deep-copies entries with preserved positions and content" do
    experience_copy = copy.sections.find_by(section_type: "experience")

    expect(experience_copy.entries.size).to eq(2)
    expect(experience_copy.entries.first.content["title"]).to eq("Staff Engineer")
    expect(experience_copy.entries.first.position).to eq(0)
    expect(experience_copy.entries.second.content["title"]).to eq("Senior Engineer")
    expect(experience_copy.entries.second.position).to eq(1)
  end

  it "does not share section or entry records with the original resume" do
    original_section_ids = resume.sections.pluck(:id)
    original_entry_ids = resume.sections.flat_map { |s| s.entries.pluck(:id) }

    copy_section_ids = copy.sections.pluck(:id)
    copy_entry_ids = copy.sections.flat_map { |s| s.entries.pluck(:id) }

    expect(copy_section_ids & original_section_ids).to be_empty
    expect(copy_entry_ids & original_entry_ids).to be_empty
  end

  it "does not copy attached pdf_export" do
    resume.pdf_export.attach(io: StringIO.new("%PDF-1.4 test"), filename: "export.pdf", content_type: "application/pdf")

    copy = described_class.new(resume: resume.reload).call

    expect(copy.pdf_export).not_to be_attached
  end
end
