require 'rails_helper'

RSpec.describe Resumes::TextExporter do
  describe '#call' do
    it 'serializes core resume details and ordered sections into plain text' do
      resume = create(
        :resume,
        title: 'Product Resume',
        headline: 'Senior Product Engineer',
        summary: 'Builds workflow systems.',
        contact_details: {
          'full_name' => 'Pat Kumar',
          'email' => 'pat@example.com',
          'phone' => '555-0100',
          'city' => 'Pune',
          'country' => 'India',
          'pin_code' => '411001',
          'website' => 'https://example.com',
          'linkedin' => 'linkedin.com/in/patkumar',
          'location' => '',
          'driving_licence' => ''
        }
      )
      experience_section = create(:section, resume:, section_type: 'experience', title: 'Experience')
      skills_section = create(:section, resume:, section_type: 'skills', title: 'Skills')
      create(
        :entry,
        section: experience_section,
        content: {
          'title' => 'Senior Product Engineer',
          'organization' => 'Acme',
          'location' => 'Remote',
          'remote' => true,
          'start_date' => '2022',
          'end_date' => '',
          'current_role' => true,
          'summary' => 'Led the guided builder rollout.',
          'highlights' => [ 'Built workflow systems', 'Shipped export improvements' ]
        }
      )
      create(:entry, section: skills_section, content: { 'name' => 'Ruby on Rails', 'level' => 'Expert' })

      text_export = described_class.new(resume: resume).call

      expect(text_export).to include('Product Resume')
      expect(text_export).to include('Senior Product Engineer')
      expect(text_export).to include('Pat Kumar | pat@example.com | 555-0100 | Pune, India 411001 | https://example.com | linkedin.com/in/patkumar')
      expect(text_export).to include("SUMMARY\nBuilds workflow systems.")
      expect(text_export).to include('Experience')
      expect(text_export).to include('Senior Product Engineer - Acme')
      expect(text_export).to include('2022 - Present | Remote | Remote')
      expect(text_export).to include('Led the guided builder rollout.')
      expect(text_export).to include('- Built workflow systems')
      expect(text_export).to include('- Shipped export improvements')
      expect(text_export).to include('Skills')
      expect(text_export).to include('Ruby on Rails - Expert')
    end

    it 'formats education, project, and generic sections while skipping sections with only blank entries' do
      resume = create(:resume, title: 'Portfolio Resume')
      education_section = create(:section, resume:, section_type: 'education', title: 'Education', position: 0)
      projects_section = create(:section, resume:, section_type: 'projects', title: 'Projects', position: 1)
      certifications_section = create(:section, resume:, section_type: 'certifications', title: 'Certifications', position: 2)
      blank_languages_section = create(:section, resume:, section_type: 'languages', title: 'Languages', position: 3)

      create(
        :entry,
        section: education_section,
        content: {
          'degree' => 'B.S. Computer Science',
          'institution' => 'State University',
          'location' => 'Boston, MA',
          'start_date' => '2016',
          'end_date' => '2020',
          'details' => 'Graduated with honors.'
        }
      )
      create(
        :entry,
        section: projects_section,
        content: {
          'name' => 'Resume Builder',
          'role' => 'Lead Engineer',
          'url' => 'https://example.com',
          'summary' => 'Built a live-editing resume platform.',
          'highlights' => [ 'Implemented Turbo-driven editing', 'Shared rendering between preview and export' ]
        }
      )
      create(
        :entry,
        section: certifications_section,
        content: {
          'name' => 'AWS Solutions Architect',
          'organization' => 'Amazon Web Services',
          'start_date' => '2023',
          'details' => 'Cloud architecture design and deployment.'
        }
      )
      create(:entry, section: blank_languages_section, content: { 'name' => '   ', 'level' => '' })

      text_export = described_class.new(resume: resume).call

      expect(text_export).to include('Education')
      expect(text_export).to include('B.S. Computer Science - State University')
      expect(text_export).to include('2016 - 2020 | Boston, MA')
      expect(text_export).to include('Graduated with honors.')
      expect(text_export).to include('Projects')
      expect(text_export).to include('Resume Builder - Lead Engineer')
      expect(text_export).to include('https://example.com')
      expect(text_export).to include('- Implemented Turbo-driven editing')
      expect(text_export).to include('Certifications')
      expect(text_export).to include('AWS Solutions Architect')
      expect(text_export).to include('Amazon Web Services')
      expect(text_export).to include('2023')
      expect(text_export).not_to include('Languages')
    end

    it 'normalizes present-date and contact whitespace while collapsing excess blank lines' do
      resume = create(
        :resume,
        title: '  Staff Resume  ',
        headline: '  Platform Lead  ',
        summary: '  Leads platform delivery.  ',
        contact_details: {
          'full_name' => '  Pat Kumar  ',
          'email' => '  pat@example.com  ',
          'phone' => ' ',
          'location' => '  Pune  ',
          'website' => '',
          'linkedin' => ' '
        }
      )
      experience_section = create(:section, resume:, section_type: 'experience', title: 'Experience', position: 0)
      blank_projects_section = create(:section, resume:, section_type: 'projects', title: 'Projects', position: 1)

      create(
        :entry,
        section: experience_section,
        content: {
          'title' => ' Platform Lead ',
          'organization' => ' Acme ',
          'location' => ' Pune ',
          'remote' => false,
          'start_date' => ' 2020 ',
          'end_date' => 'Current',
          'current_role' => false,
          'summary' => '  Scaling platform workflows.  ',
          'highlights' => [ '  Cut export latency  ', '   ' ]
        }
      )
      create(:entry, section: blank_projects_section, content: { 'name' => '', 'role' => nil, 'summary' => '   ', 'highlights' => [ '' ] })

      text_export = described_class.new(resume: resume).call

      expect(text_export).to include('Staff Resume')
      expect(text_export).to include('Platform Lead')
      expect(text_export).to include('Pat Kumar | pat@example.com | Pune')
      expect(text_export).to include('Platform Lead - Acme')
      expect(text_export).to include('2020 - Present | Pune')
      expect(text_export).not_to include('Remote')
      expect(text_export).not_to include("\n\n\n")
      expect(text_export).to end_with("\n")
      expect(text_export).not_to include('Projects')
    end
  end
end
