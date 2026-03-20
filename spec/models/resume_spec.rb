require 'rails_helper'

RSpec.describe Resume, type: :model do
  describe 'callbacks' do
    it 'assigns the default template and normalizes stored JSON values' do
      template = create(:template)

      resume = described_class.create!(
        user: create(:user),
        title: 'Lead Resume',
        template: nil,
        slug: nil,
        source_mode: 'unknown',
        source_text: nil,
        contact_details: { full_name: 'Casey Example' },
        settings: { show_contact_icons: 'false' },
        summary: 'Summary'
      )

      expect(resume.template).to eq(template)
      expect(resume.slug).to eq('lead-resume')
      expect(resume.contact_details).to include(
        'full_name' => 'Casey Example',
        'first_name' => '',
        'surname' => '',
        'city' => '',
        'country' => '',
        'pin_code' => '',
        'location' => ''
      )
      expect(resume.personal_details).to include(
        'date_of_birth' => '',
        'nationality' => '',
        'marital_status' => '',
        'visa_status' => ''
      )
      expect(resume.source_mode).to eq('scratch')
      expect(resume.source_text).to eq('')
      expect(resume.settings['show_contact_icons']).to eq(false)
    end

    it 'derives full_name and location from split contact fields' do
      resume = described_class.create!(
        user: create(:user),
        title: 'Lead Resume',
        template: create(:template),
        slug: nil,
        contact_details: {
          first_name: 'Casey',
          surname: 'Example',
          city: 'Boston',
          country: 'USA',
          pin_code: '02108'
        },
        settings: {},
        summary: 'Summary'
      )

      expect(resume.contact_details).to include(
        'full_name' => 'Casey Example',
        'location' => 'Boston, USA 02108'
      )
      expect(resume.contact_field('full_name')).to eq('Casey Example')
      expect(resume.contact_field('location')).to eq('Boston, USA 02108')
      expect(resume.contact_field('first_name')).to eq('Casey')
      expect(resume.contact_field('surname')).to eq('Example')
    end

    it 'normalizes intake details to supported string-key values' do
      resume = described_class.create!(
        user: create(:user),
        title: 'Lead Resume',
        template: create(:template),
        slug: nil,
        contact_details: {},
        intake_details: {
          experience_level: :less_than_3_years,
          student_status: :student,
          ignored_key: 'ignore me'
        },
        settings: {},
        summary: 'Summary'
      )

      expect(resume.intake_details).to eq(
        'experience_level' => 'less_than_3_years',
        'student_status' => 'student'
      )
      expect(resume.experience_level).to eq('less_than_3_years')
      expect(resume.student_status).to eq('student')
    end

    it 'keeps unsupported or missing intake values safe' do
      resume = described_class.create!(
        user: create(:user),
        title: 'Lead Resume',
        template: create(:template),
        slug: nil,
        contact_details: {},
        intake_details: {
          experience_level: 'unexpected',
          student_status: 'advisor'
        },
        settings: {},
        summary: 'Summary'
      )

      expect(resume.intake_details).to eq(
        'experience_level' => '',
        'student_status' => ''
      )
      expect(resume.experience_level).to eq('')
      expect(resume.student_status).to eq('')
    end

    it 'normalizes optional personal details to supported string-key values' do
      resume = described_class.create!(
        user: create(:user),
        title: 'Lead Resume',
        template: create(:template),
        slug: nil,
        contact_details: {},
        personal_details: {
          date_of_birth: '1994-02-14',
          nationality: 'Indian',
          marital_status: 'Single',
          visa_status: 'Requires sponsorship',
          passport: 'ignore me'
        },
        settings: {},
        summary: 'Summary'
      )

      expect(resume.personal_details).to eq(
        'date_of_birth' => '1994-02-14',
        'nationality' => 'Indian',
        'marital_status' => 'Single',
        'visa_status' => 'Requires sponsorship'
      )
      expect(resume.personal_detail_field('visa_status')).to eq('Requires sponsorship')
    end
  end

  describe '#ordered_sections' do
    it 'returns sections ordered by position' do
      resume = create(:resume)
      earlier_section = create(:section, resume:, title: 'Experience', position: 1, section_type: 'experience')
      later_section = create(:section, resume:, title: 'Projects', position: 2, section_type: 'projects')

      expect(resume.ordered_sections.to_a).to eq([earlier_section, later_section])
    end
  end

  describe '#export_state' do
    it 'returns draft when no export job or attachment exists' do
      expect(create(:resume).export_state).to eq('draft')
    end

    it 'returns ready when a PDF attachment is present and no pending export exists' do
      resume = create(:resume)
      resume.pdf_export.attach(io: StringIO.new('%PDF-1.4 test content'), filename: "#{resume.slug}.pdf", content_type: 'application/pdf')

      expect(resume.export_state).to eq('ready')
    end

    it 'prefers the latest queued export over an older attached PDF' do
      resume = create(:resume)
      resume.pdf_export.attach(io: StringIO.new('%PDF-1.4 test content'), filename: "#{resume.slug}.pdf", content_type: 'application/pdf')
      create(:job_log, input: { 'arguments' => [resume.id, resume.user.id] }, status: 'queued')

      expect(resume.export_state).to eq('queued')
    end

    it 'returns failed when the latest export job failed' do
      resume = create(:resume)
      create(:job_log, :failed, input: { 'arguments' => [resume.id, resume.user.id] })

      expect(resume.export_state).to eq('failed')
    end
  end

  describe '#source_step_completed?' do
    it 'treats scratch mode as complete' do
      expect(create(:resume, source_mode: 'scratch').source_step_completed?).to eq(true)
    end

    it 'requires pasted source text when the mode is paste' do
      resume = create(:resume, source_mode: 'paste', source_text: '')

      expect(resume.source_step_completed?).to eq(false)

      resume.update!(source_text: 'Existing resume content')

      expect(resume.source_step_completed?).to eq(true)
    end

    it 'requires an attached source document when the mode is upload' do
      resume = create(:resume, source_mode: 'upload')

      expect(resume.source_step_completed?).to eq(false)

      resume.source_document.attach(io: StringIO.new('resume source'), filename: 'source.txt', content_type: 'text/plain')

      expect(resume.source_step_completed?).to eq(true)
    end
  end
end
