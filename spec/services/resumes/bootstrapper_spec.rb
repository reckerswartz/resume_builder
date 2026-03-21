require 'rails_helper'

RSpec.describe Resumes::Bootstrapper do
  describe '#call' do
    it 'assigns a unique slug when the user already has a resume with the same title' do
      template = create(:template, name: 'Modern', slug: 'modern')
      user = create(:user)
      create(:resume, user:, template:, title: 'Untitled Resume', slug: 'untitled-resume')

      resume = described_class.new(user:).call(title: 'Untitled Resume', template:)

      expect(resume).to be_persisted
      expect(resume.slug).to eq('untitled-resume-2')
      expect(resume.sections.count).to eq(ResumeBuilder::SectionRegistry.starter_sections.size)
    end

    it 'persists normalized intake details on the created resume' do
      template = create(:template, name: 'Modern', slug: 'modern')
      user = create(:user)

      resume = described_class.new(user:).call(
        title: 'Untitled Resume',
        template:,
        intake_details: {
          experience_level: :less_than_3_years,
          student_status: :student
        }
      )

      expect(resume).to be_persisted
      expect(resume.intake_details).to eq(
        'experience_level' => 'less_than_3_years',
        'student_status' => 'student'
      )
    end

    it 'persists normalized personal details and optional credentials on the created resume' do
      template = create(:template, name: 'Modern', slug: 'modern')
      user = create(:user)

      resume = described_class.new(user:).call(
        title: 'Untitled Resume',
        template:,
        contact_details: {
          website: ' https://portfolio.example.com ',
          driving_licence: ' B '
        },
        personal_details: {
          date_of_birth: '1994-02-14',
          nationality: 'Indian',
          visa_status: 'Requires sponsorship'
        }
      )

      expect(resume).to be_persisted
      expect(resume.contact_details).to include(
        'website' => 'https://portfolio.example.com',
        'driving_licence' => 'B'
      )
      expect(resume.personal_details).to eq(
        'date_of_birth' => '1994-02-14',
        'nationality' => 'Indian',
        'marital_status' => '',
        'visa_status' => 'Requires sponsorship'
      )
    end

    it 'uses the selected template render profile accent color in default settings' do
      template = create(
        :template,
        name: 'Classic Ivory',
        slug: 'classic-ivory',
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic')
      )
      user = create(:user)

      resume = described_class.new(user:).call(title: 'Classic Resume', template: template)

      expect(resume).to be_persisted
      expect(resume.settings).to include(
        'accent_color' => template.render_layout_config.fetch('accent_color'),
        'show_contact_icons' => true,
        'page_size' => 'A4'
      )
    end
  end
end
