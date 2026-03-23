require 'rails_helper'

RSpec.describe ResumeTemplates::ModernComponent, type: :component do
  subject(:component) { described_class.new(resume:) }

  let(:family) { 'modern' }
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
      'accent_color' => '#0F172A',
      'show_contact_icons' => true,
      'page_size' => 'A4'
    }
  end
  let(:contact_details) do
    {
      'full_name' => '',
      'first_name' => 'Casey',
      'surname' => 'Park',
      'email' => 'casey@example.com',
      'phone' => '555-0105',
      'location' => '',
      'city' => 'Seattle',
      'country' => 'USA',
      'website' => '',
      'linkedin' => 'https://linkedin.com/in/casey',
      'driving_licence' => ''
    }
  end
  let(:resume) do
    create(
      :resume,
      template:,
      settings:,
      contact_details:,
      headline: 'Staff Engineer',
      summary: 'Shipping reliable distributed systems at scale.'
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
        'title' => 'Staff Engineer',
        'organization' => 'CloudCo',
        'role' => 'Platform',
        'start_date' => '2020',
        'current_role' => true,
        'summary' => 'Designed the shared infrastructure layer.',
        'highlights' => [ 'Reduced incident response time by 60%' ],
        'url' => 'https://cloudco.example.com'
      }
    )
  end
  let!(:skills_section) do
    create(:section, resume:, title: 'Skills', section_type: 'skills', position: 1)
  end
  let!(:skill_entry) do
    create(:entry, section: skills_section, content: { 'name' => 'Go', 'level' => 'Advanced' })
  end

  describe 'rendering' do
    before { render_inline(component) }

    it 'renders the full name styled with the accent color' do
      expect(rendered_content).to include('Casey Park')
      expect(rendered_content).to include('color: #0F172A')
    end

    it 'renders the headline and summary' do
      expect(rendered_content).to include('Staff Engineer')
      expect(rendered_content).to include('Shipping reliable distributed systems at scale.')
    end

    it 'renders contact items as labeled pills' do
      expect(rendered_content).to include('Email:')
      expect(rendered_content).to include('casey@example.com')
      expect(rendered_content).to include('Phone:')
      expect(rendered_content).to include('555-0105')
      expect(rendered_content).to include('LinkedIn:')
    end

    it 'renders marker-style section headings with accent-colored dots' do
      expect(rendered_content).to include('Experience')
      expect(rendered_content).to include('Skills')
      expect(rendered_content).to include('rounded-full')
    end

    it 'renders experience entries with title, subtitle, and highlights' do
      expect(rendered_content).to include('Staff Engineer')
      expect(rendered_content).to include('CloudCo')
      expect(rendered_content).to include('Platform')
      expect(rendered_content).to include('2020 - Current')
      expect(rendered_content).to include('Designed the shared infrastructure layer.')
      expect(rendered_content).to include('Reduced incident response time by 60%')
    end

    it 'renders skills as chip pills by default' do
      expect(rendered_content).to include('Go')
      expect(rendered_content).to include('Advanced')
      expect(rendered_content).to include('rounded-full')
    end

    it 'uses card shell chrome' do
      expect(rendered_content).to include('rounded-[2rem]')
      expect(rendered_content).to include('shadow-sm')
    end
  end

  describe 'rendering with inline skill style' do
    let(:template) do
      config = ResumeTemplates::Catalog.default_layout_config(family: family).merge('skill_style' => 'inline')
      create(
        :template,
        name: ResumeTemplates::Catalog.family_label(family),
        slug: "#{family}-inline-#{SecureRandom.hex(4)}",
        layout_config: config
      )
    end

    before { render_inline(component) }

    it 'renders skills as an inline pipe-separated summary' do
      expect(rendered_content).to include('Go (Advanced)')
    end
  end
end
