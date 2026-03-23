require 'rails_helper'

RSpec.describe ResumeTemplates::ModernCleanComponent, type: :component do
  subject(:component) { described_class.new(resume:) }

  let(:family) { 'modern-clean' }
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
      'accent_color' => '#0D6B63',
      'show_contact_icons' => true,
      'page_size' => 'A4'
    }
  end
  let(:contact_details) do
    {
      'full_name' => '',
      'first_name' => 'Alex',
      'surname' => 'Nakamura',
      'email' => 'alex@example.com',
      'phone' => '555-0104',
      'location' => '',
      'city' => 'Tokyo',
      'country' => 'Japan',
      'website' => 'https://alex.dev',
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
      headline: 'Frontend Architect',
      summary: 'Building accessible and performant web experiences.'
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
        'title' => 'Frontend Lead',
        'organization' => 'WebCo',
        'start_date' => '2022',
        'current_role' => true,
        'summary' => 'Architected the component system.',
        'highlights' => [ 'Improved Lighthouse score to 98' ],
        'url' => 'https://webco.example.com'
      }
    )
  end
  let!(:skills_section) do
    create(:section, resume:, title: 'Skills', section_type: 'skills', position: 1)
  end
  let!(:skill_entry) do
    create(:entry, section: skills_section, content: { 'name' => 'TypeScript', 'level' => 'Expert' })
  end

  describe 'rendering' do
    before { render_inline(component) }

    it 'renders the full name and headline' do
      expect(rendered_content).to include('Alex Nakamura')
      expect(rendered_content).to include('Frontend Architect')
    end

    it 'renders the summary' do
      expect(rendered_content).to include('Building accessible and performant web experiences.')
    end

    it 'renders the template name badge' do
      expect(rendered_content).to include(template.name)
    end

    it 'renders contact items as rounded pill chips' do
      expect(rendered_content).to include('alex@example.com')
      expect(rendered_content).to include('555-0104')
      expect(rendered_content).to include('https://alex.dev')
    end

    it 'renders section headings with a horizontal rule' do
      expect(rendered_content).to include('Experience')
      expect(rendered_content).to include('Skills')
    end

    it 'renders experience entries in card-style articles' do
      expect(rendered_content).to include('Frontend Lead')
      expect(rendered_content).to include('WebCo')
      expect(rendered_content).to include('2022 - Current')
      expect(rendered_content).to include('Architected the component system.')
      expect(rendered_content).to include('Improved Lighthouse score to 98')
      expect(rendered_content).to include('https://webco.example.com')
      expect(rendered_content).to include('rounded-xl')
    end

    it 'renders skills as accent-tinted chips' do
      expect(rendered_content).to include('TypeScript')
      expect(rendered_content).to include('Expert')
      expect(rendered_content).to include('rounded-full')
    end

    it 'uses card shell chrome' do
      expect(rendered_content).to include('rounded-[2rem]')
    end
  end
end
