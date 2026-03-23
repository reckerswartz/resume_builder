require 'rails_helper'

RSpec.describe ResumeTemplates::ProfessionalComponent, type: :component do
  subject(:component) { described_class.new(resume:) }

  let(:family) { 'professional' }
  let(:template) do
    create(
      :template,
      name: ResumeTemplates::Catalog.family_label(family),
      slug: "#{family}-#{SecureRandom.hex(4)}",
      layout_config: ResumeTemplates::Catalog.default_layout_config(family: family)
    )
  end
  let(:settings) do
    {
      'accent_color' => '#0F4C81',
      'show_contact_icons' => true,
      'page_size' => 'A4'
    }
  end
  let(:contact_details) do
    {
      'full_name' => '',
      'first_name' => 'Sam',
      'surname' => 'Torres',
      'email' => 'sam@example.com',
      'phone' => '555-0106',
      'location' => '',
      'city' => 'London',
      'country' => 'UK',
      'website' => '',
      'linkedin' => '',
      'driving_licence' => ''
    }
  end
  let(:resume) do
    create(
      :resume,
      template:,
      settings:,
      contact_details:,
      headline: 'Engineering Manager',
      summary: 'Scaling high-performance engineering teams across time zones.'
    )
  end

  let!(:experience_section) do
    create(:section, resume:, title: 'Experience', section_type: 'experience', position: 0)
  end
  let!(:experience_entry) do
    create(
      :entry,
      section: experience_section,
      content: {
        'title' => 'Engineering Manager',
        'organization' => 'FinTech Ltd',
        'start_date' => '2019',
        'current_role' => true,
        'summary' => 'Managed a distributed team of 12 engineers.',
        'highlights' => [ 'Grew team from 4 to 12 in 18 months' ],
        'url' => 'https://fintech.example.com'
      }
    )
  end
  let!(:skills_section) do
    create(:section, resume:, title: 'Skills', section_type: 'skills', position: 1)
  end
  let!(:skill_entry) do
    create(:entry, section: skills_section, content: { 'name' => 'Leadership', 'level' => 'Expert' })
  end

  describe 'rendering' do
    before { render_inline(component) }

    it 'renders the full name and headline' do
      expect(rendered_content).to include('Sam Torres')
      expect(rendered_content).to include('Engineering Manager')
    end

    it 'renders the accent bar above the header' do
      expect(rendered_content).to include('h-1.5 w-20 rounded-full')
    end

    it 'renders contact items with bold labels and dot separators' do
      expect(rendered_content).to include('Email')
      expect(rendered_content).to include('sam@example.com')
      expect(rendered_content).to include('Phone')
      expect(rendered_content).to include('555-0106')
    end

    it 'renders the summary in an accent-bordered callout card' do
      expect(rendered_content).to include('Scaling high-performance engineering teams across time zones.')
      expect(rendered_content).to include('border-l-[3px]')
      expect(rendered_content).to include('rounded-2xl')
    end

    it 'renders section headings with left accent border and bottom rule' do
      expect(rendered_content).to include('Experience')
      expect(rendered_content).to include('Skills')
      expect(rendered_content).to include('border-b-2')
      expect(rendered_content).to include('border-l-[3px]')
    end

    it 'renders experience entries with a left border timeline' do
      expect(rendered_content).to include('Engineering Manager')
      expect(rendered_content).to include('FinTech Ltd')
      expect(rendered_content).to include('2019 - Current')
      expect(rendered_content).to include('Managed a distributed team of 12 engineers.')
      expect(rendered_content).to include('Grew team from 4 to 12 in 18 months')
      expect(rendered_content).to include('border-l-2')
    end

    it 'renders skills in a two-column grid with cards' do
      expect(rendered_content).to include('Leadership')
      expect(rendered_content).to include('Expert')
      expect(rendered_content).to include('sm:grid-cols-2')
    end

    it 'uses a flat shell without card chrome' do
      expect(rendered_content).not_to include('rounded-[2rem]')
    end
  end
end
