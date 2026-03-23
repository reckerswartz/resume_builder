require 'rails_helper'

RSpec.describe ResumeTemplates::SidebarAccentComponent, type: :component do
  subject(:component) { described_class.new(resume:) }

  let(:family) { 'sidebar-accent' }
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
      'accent_color' => '#4338CA',
      'show_contact_icons' => true,
      'page_size' => 'A4'
    }
  end
  let(:contact_details) do
    {
      'full_name' => '',
      'first_name' => 'Riley',
      'surname' => 'Kim',
      'email' => 'riley@example.com',
      'phone' => '555-0107',
      'location' => '',
      'city' => 'Toronto',
      'country' => 'Canada',
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
      headline: 'Data Scientist',
      summary: 'Turning complex data into actionable product insights.'
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
        'title' => 'Senior Data Scientist',
        'organization' => 'DataCorp',
        'start_date' => '2021',
        'current_role' => true,
        'summary' => 'Built ML pipelines for recommendation engine.',
        'highlights' => [ 'Improved model accuracy by 15%' ],
        'url' => 'https://datacorp.example.com'
      }
    )
  end
  let!(:skills_section) do
    create(:section, resume:, title: 'Skills', section_type: 'skills', position: 1)
  end
  let!(:skill_entry) do
    create(:entry, section: skills_section, content: { 'name' => 'Python', 'level' => 'Expert' })
  end
  let!(:education_section) do
    create(:section, resume:, title: 'Education', section_type: 'education', position: 2)
  end
  let!(:education_entry) do
    create(
      :entry,
      section: education_section,
      content: {
        'degree' => 'MSc Statistics',
        'institution' => 'University of Toronto',
        'start_date' => '2017',
        'end_date' => '2019'
      }
    )
  end

  describe 'component helpers' do
    it 'defaults sidebar to the left position' do
      expect(component.sidebar_left?).to be(true)
    end

    it 'routes skills and education to the sidebar' do
      expect(component.sidebar_sections.map(&:section_type)).to contain_exactly('skills', 'education')
    end

    it 'routes experience to the main content area' do
      expect(component.main_sections.map(&:section_type)).to eq([ 'experience' ])
    end
  end

  describe 'rendering' do
    before { render_inline(component) }

    it 'renders the full name and headline in the sidebar' do
      expect(rendered_content).to include('Riley Kim')
      expect(rendered_content).to include('Data Scientist')
    end

    it 'renders the template name in the sidebar' do
      expect(rendered_content).to include(template.name)
    end

    it 'renders the summary in a profile section in the main area' do
      expect(rendered_content).to include('Profile')
      expect(rendered_content).to include('Turning complex data into actionable product insights.')
    end

    it 'renders contact details in the sidebar with label-value pairs' do
      expect(rendered_content).to include('Contact')
      expect(rendered_content).to include('Email')
      expect(rendered_content).to include('riley@example.com')
      expect(rendered_content).to include('Phone')
      expect(rendered_content).to include('555-0107')
    end

    it 'renders experience entries in the main area' do
      expect(rendered_content).to include('Experience')
      expect(rendered_content).to include('Senior Data Scientist')
      expect(rendered_content).to include('DataCorp')
      expect(rendered_content).to include('2021 - Current')
      expect(rendered_content).to include('Built ML pipelines for recommendation engine.')
      expect(rendered_content).to include('Improved model accuracy by 15%')
    end

    it 'renders skills in the sidebar as chips' do
      expect(rendered_content).to include('Skills')
      expect(rendered_content).to include('Python')
      expect(rendered_content).to include('Expert')
      expect(rendered_content).to include('rounded-full')
    end

    it 'renders education in the sidebar' do
      expect(rendered_content).to include('Education')
      expect(rendered_content).to include('MSc Statistics')
      expect(rendered_content).to include('University of Toronto')
      expect(rendered_content).to include('2017 - 2019')
    end

    it 'renders the sidebar with an accent-tinted background' do
      expect(rendered_content).to include('background-color: #4338CA15')
    end

    it 'uses card shell chrome' do
      expect(rendered_content).to include('rounded-[2rem]')
    end
  end

  describe 'rendering with right sidebar position' do
    let(:template) do
      config = ResumeTemplates::Catalog.default_layout_config(family: family).merge('sidebar_position' => 'right')
      create(
        :template,
        name: ResumeTemplates::Catalog.family_label(family),
        slug: "#{family}-right-#{SecureRandom.hex(4)}",
        layout_config: config
      )
    end

    it 'positions the sidebar on the right' do
      expect(component.sidebar_left?).to be(false)
    end

    it 'renders with right-side border on the sidebar' do
      render_inline(component)
      expect(rendered_content).to include('border-l')
      expect(rendered_content).to include('lg:order-2')
    end
  end
end
