require 'rails_helper'

RSpec.describe ResumeTemplates::AtsMinimalComponent, type: :component do
  subject(:component) { described_class.new(resume:) }

  let(:family) { 'ats-minimal' }
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
      'accent_color' => '#334155',
      'show_contact_icons' => true,
      'page_size' => 'A4'
    }
  end
  let(:contact_details) do
    {
      'full_name' => '',
      'first_name' => 'Taylor',
      'surname' => 'Chen',
      'email' => 'taylor@example.com',
      'phone' => '555-0101',
      'location' => '',
      'city' => 'Austin',
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
      headline: 'Software Engineer',
      summary: 'Experienced engineer with a focus on backend systems.'
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
        'title' => 'Senior Engineer',
        'organization' => 'Acme Corp',
        'start_date' => '2021',
        'current_role' => true,
        'summary' => 'Led backend platform initiatives.',
        'highlights' => [ 'Reduced deploy time by 40%' ],
        'url' => 'https://acme.example.com'
      }
    )
  end
  let!(:skills_section) do
    create(:section, resume:, title: 'Skills', section_type: 'skills', position: 1)
  end
  let!(:skill_entry) do
    create(:entry, section: skills_section, content: { 'name' => 'Ruby', 'level' => 'Expert' })
  end

  describe 'rendering' do
    before { render_inline(component) }

    it 'renders the full name and headline in the header' do
      expect(rendered_content).to include('Taylor Chen')
      expect(rendered_content).to include('Software Engineer')
    end

    it 'renders the summary paragraph' do
      expect(rendered_content).to include('Experienced engineer with a focus on backend systems.')
    end

    it 'renders contact items joined by a separator' do
      expect(rendered_content).to include('taylor@example.com')
      expect(rendered_content).to include('555-0101')
    end

    it 'renders the header with a thin accent-colored border' do
      expect(rendered_content).to include('border-b-2')
    end

    it 'renders section headings with accent-colored rule markers' do
      expect(rendered_content).to include('Experience')
      expect(rendered_content).to include('Skills')
    end

    it 'renders experience entries with title, subtitle, date range, and highlights' do
      expect(rendered_content).to include('Senior Engineer')
      expect(rendered_content).to include('Acme Corp')
      expect(rendered_content).to include('2021 - Current')
      expect(rendered_content).to include('Led backend platform initiatives.')
      expect(rendered_content).to include('Reduced deploy time by 40%')
      expect(rendered_content).to include('https://acme.example.com')
    end

    it 'renders skills as an inline summary' do
      expect(rendered_content).to include('Ruby (Expert)')
    end

    it 'uses a flat shell without card chrome' do
      expect(rendered_content).not_to include('rounded-[2rem]')
    end
  end
end
