require 'rails_helper'

RSpec.describe ResumeTemplates::ClassicComponent, type: :component do
  subject(:component) { described_class.new(resume:) }

  let(:family) { 'classic' }
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
      'accent_color' => '#1D4ED8',
      'show_contact_icons' => true,
      'page_size' => 'A4'
    }
  end
  let(:contact_details) do
    {
      'full_name' => '',
      'first_name' => 'Morgan',
      'surname' => 'Blake',
      'email' => 'morgan@example.com',
      'phone' => '555-0102',
      'location' => '',
      'city' => 'Chicago',
      'country' => 'USA',
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
      headline: 'Product Manager',
      summary: 'Seasoned PM with cross-functional delivery experience.'
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
        'title' => 'Lead PM',
        'organization' => 'BigCo',
        'start_date' => '2020',
        'end_date' => '2023',
        'summary' => 'Owned the product roadmap.',
        'highlights' => [ 'Shipped v2 on schedule' ],
        'url' => 'https://bigco.example.com'
      }
    )
  end
  let!(:skills_section) do
    create(:section, resume:, title: 'Skills', section_type: 'skills', position: 1)
  end
  let!(:skill_entry) do
    create(:entry, section: skills_section, content: { 'name' => 'Agile', 'level' => 'Advanced' })
  end

  describe 'rendering' do
    before { render_inline(component) }

    it 'renders the full name and headline' do
      expect(rendered_content).to include('Morgan Blake')
      expect(rendered_content).to include('Product Manager')
    end

    it 'renders the summary' do
      expect(rendered_content).to include('Seasoned PM with cross-functional delivery experience.')
    end

    it 'renders the header with a thick accent border' do
      expect(rendered_content).to include('border-b-[3px]')
    end

    it 'renders contact details' do
      expect(rendered_content).to include('morgan@example.com')
      expect(rendered_content).to include('555-0102')
    end

    it 'renders experience entries with a date range' do
      expect(rendered_content).to include('Lead PM')
      expect(rendered_content).to include('BigCo')
      expect(rendered_content).to include('2020 - 2023')
      expect(rendered_content).to include('Owned the product roadmap.')
      expect(rendered_content).to include('Shipped v2 on schedule')
    end

    it 'renders skills as an inline summary by default' do
      expect(rendered_content).to include('Agile (Advanced)')
    end

    it 'uses a flat shell without card chrome' do
      expect(rendered_content).not_to include('rounded-[2rem]')
    end
  end

  describe 'rendering with marker section headings' do
    let(:template) do
      config = ResumeTemplates::Catalog.default_layout_config(family: family).merge('section_heading_style' => 'marker')
      create(
        :template,
        name: ResumeTemplates::Catalog.family_label(family),
        slug: "#{family}-marker-#{SecureRandom.hex(4)}",
        layout_config: config
      )
    end

    before { render_inline(component) }

    it 'renders marker dots next to section headings' do
      expect(rendered_content).to include('rounded-full')
    end
  end

  describe 'rendering with chip skill style' do
    let(:template) do
      config = ResumeTemplates::Catalog.default_layout_config(family: family).merge('skill_style' => 'chips')
      create(
        :template,
        name: ResumeTemplates::Catalog.family_label(family),
        slug: "#{family}-chips-#{SecureRandom.hex(4)}",
        layout_config: config
      )
    end

    before { render_inline(component) }

    it 'renders skills as rounded pill chips' do
      expect(rendered_content).to include('Agile')
      expect(rendered_content).to include('Advanced')
      expect(rendered_content).to include('rounded-full')
    end
  end
end
