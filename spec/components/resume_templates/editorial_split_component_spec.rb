require 'rails_helper'

RSpec.describe ResumeTemplates::EditorialSplitComponent, type: :component do
  subject(:component) { described_class.new(resume:) }

  let(:family) { 'editorial-split' }
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
      'accent_color' => '#D7F038',
      'show_contact_icons' => true,
      'page_size' => 'A4'
    }
  end
  let(:contact_details) do
    {
      'full_name' => '',
      'first_name' => 'Jordan',
      'surname' => 'Rivera',
      'email' => 'jordan@example.com',
      'phone' => '555-0103',
      'location' => '',
      'city' => 'Berlin',
      'country' => 'Germany',
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
      headline: 'Design Engineer',
      summary: 'Full-stack designer-developer bridging product and engineering.'
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
        'title' => 'Design Engineer',
        'organization' => 'Studio',
        'start_date' => '2021',
        'current_role' => true,
        'summary' => 'Built and maintained the design system.',
        'highlights' => [ 'Unified component library across teams' ],
        'url' => 'https://studio.example.com'
      }
    )
  end
  let!(:education_section) do
    create(:section, resume:, title: 'Education', section_type: 'education', position: 1)
  end
  let!(:education_entry) do
    create(
      :entry,
      section: education_section,
      content: {
        'degree' => 'BSc Computer Science',
        'institution' => 'TU Berlin',
        'start_date' => '2015',
        'end_date' => '2019'
      }
    )
  end
  let!(:skills_section) do
    create(:section, resume:, title: 'Skills', section_type: 'skills', position: 2)
  end
  let!(:skill_entry) do
    create(:entry, section: skills_section, content: { 'name' => 'Figma', 'level' => 'Expert' })
  end

  describe 'component helpers' do
    it 'splits the full name into leading, accent, and trailing segments' do
      expect(component.leading_name).to eq('Jordan')
      expect(component.accent_name).to eq('Rivera')
      expect(component.trailing_name).to eq('')
    end

    it 'builds identity initials from the first two name segments' do
      expect(component.identity_initials).to eq('JR')
    end

    it 'limits header and rail contact items to three' do
      expect(component.header_contact_items.length).to be <= 3
      expect(component.rail_contact_items.length).to be <= 3
    end

    it 'maps contact labels to short badge labels' do
      expect(component.contact_badge_label('Email')).to eq('@')
      expect(component.contact_badge_label('Phone')).to eq('P')
      expect(component.contact_badge_label('LinkedIn')).to eq('in')
    end

    it 'routes education and skills to the sidebar, experience to the main area' do
      expect(component.sidebar_sections.map(&:section_type)).to include('education', 'skills')
      expect(component.main_sections.map(&:section_type)).to include('experience')
    end
  end

  describe 'rendering' do
    before { render_inline(component) }

    it 'renders the name with editorial split styling' do
      expect(rendered_content).to include('JORDAN')
      expect(rendered_content).to include('RIVERA')
    end

    it 'renders initials in the avatar placeholder when no headshot is attached' do
      expect(rendered_content).to include('JR')
    end

    it 'renders the headline' do
      expect(rendered_content).to include('Design Engineer')
    end

    it 'renders the summary under a profile heading' do
      expect(rendered_content).to include('Full-stack designer-developer bridging product and engineering.')
    end

    it 'renders sidebar sections (education, skills)' do
      expect(rendered_content).to include('Education')
      expect(rendered_content).to include('BSc Computer Science')
      expect(rendered_content).to include('TU Berlin')
      expect(rendered_content).to include('Skills')
      expect(rendered_content).to include('Figma')
    end

    it 'renders main sections (experience)' do
      expect(rendered_content).to include('Experience')
      expect(rendered_content).to include('Design Engineer')
      expect(rendered_content).to include('Studio')
      expect(rendered_content).to include('2021 - Current')
      expect(rendered_content).to include('Unified component library across teams')
    end

    it 'renders utility badges for paper sizes' do
      expect(rendered_content).to include('A4')
      expect(rendered_content).to include('Paper size')
    end

    it 'renders contact badge labels in the rail' do
      expect(rendered_content).to include(component.contact_badge_label('Email'))
    end

    it 'renders the template name in the vertical aside' do
      expect(rendered_content).to include(template.name)
    end
  end

  describe 'rendering with headshot' do
    before do
      resume.headshot.attach(io: StringIO.new('image-bytes'), filename: 'headshot.png', content_type: 'image/png')
      render_inline(component)
    end

    it 'renders a headshot image instead of initials' do
      expect(rendered_content).to include('Jordan Rivera headshot')
      expect(rendered_content).to include('data:image/png;base64,')
    end
  end
end
