require 'rails_helper'

RSpec.describe Resume, type: :model do
  def create_ready_photo_asset(photo_profile:, filename:, asset_kind: :enhanced)
    PhotoAsset.new(photo_profile:, asset_kind:, status: :ready).tap do |photo_asset|
      photo_asset.file.attach(io: StringIO.new('image-bytes'), filename:, content_type: 'image/png')
      photo_asset.save!
    end
  end

  describe 'callbacks' do
    it 'assigns the default template and normalizes stored JSON values' do
      template = create(:template, layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic'))

      resume = described_class.create!(
        user: create(:user),
        title: 'Lead Resume',
        template: nil,
        slug: nil,
        source_mode: 'unknown',
        source_text: nil,
        contact_details: { full_name: 'Casey Example' },
        settings: { show_contact_icons: 'false', page_size: 'Legal', font_scale: 'giant', density: 'airy', hidden_sections: %w[projects unexpected projects] },
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
      expect(resume.page_size).to eq('A4')
      expect(resume.font_scale).to eq('sm')
      expect(resume.density).to eq('compact')
      expect(resume.hidden_section_types).to eq(['projects'])
    end

    it 'removes blank font scale and density overrides so template defaults still apply' do
      template = create(:template, layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'classic'))

      resume = described_class.create!(
        user: create(:user),
        title: 'Classic Resume',
        template: template,
        slug: nil,
        contact_details: {},
        settings: { accent_color: '#1D4ED8', page_size: 'A4', show_contact_icons: true, font_scale: '', density: '' },
        summary: 'Summary'
      )

      expect(resume.settings).not_to have_key('font_scale')
      expect(resume.settings).not_to have_key('density')
      expect(resume.font_scale).to eq('sm')
      expect(resume.density).to eq('compact')
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

  describe 'headshot support' do
    it 'accepts supported headshot image content types' do
      resume = create(:resume)
      resume.headshot.attach(io: StringIO.new('image-bytes'), filename: 'headshot.png', content_type: 'image/png')

      expect(resume).to be_valid
    end

    it 'rejects unsupported headshot content types' do
      resume = create(:resume)
      resume.headshot.attach(io: StringIO.new('not-an-image'), filename: 'headshot.txt', content_type: 'text/plain')

      expect(resume).not_to be_valid
      expect(resume.errors[:headshot]).to include('must be a JPG, PNG, or WebP image')
    end

    it 'rejects headshots larger than the maximum allowed size' do
      resume = create(:resume)
      resume.headshot.attach(io: StringIO.new('a' * (Resume::MAX_HEADSHOT_SIZE + 1)), filename: 'headshot.png', content_type: 'image/png')

      expect(resume).not_to be_valid
      expect(resume.errors[:headshot]).to include('must be smaller than 3 MB')
    end

    it 'treats an attached headshot as completing the personal details step' do
      resume = create(:resume, personal_details: {}, contact_details: { 'full_name' => 'Pat Kumar', 'email' => 'pat@example.com', 'website' => '', 'linkedin' => '', 'driving_licence' => '' })

      expect(resume.personal_details_step_completed?).to eq(false)

      resume.headshot.attach(io: StringIO.new('image-bytes'), filename: 'headshot.png', content_type: 'image/png')

      expect(resume.personal_details_step_completed?).to eq(true)
    end

    it 'prefers an active template-specific selected photo asset over the photo profile fallback' do
      user = create(:user)
      photo_profile = PhotoProfile.create!(user:, name: 'Pat Kumar Photo Library', status: :active)
      fallback_asset = create_ready_photo_asset(photo_profile:, filename: 'fallback-headshot.png', asset_kind: :enhanced)
      selected_asset = create_ready_photo_asset(photo_profile:, filename: 'selected-headshot.png', asset_kind: :source)
      resume = create(:resume, user:, photo_profile:)

      expect(photo_profile.preferred_headshot_asset).to eq(fallback_asset)

      ResumePhotoSelection.create!(
        resume:,
        template: resume.template,
        photo_asset: selected_asset,
        slot_name: 'headshot',
        status: :active
      )

      expect(resume.selected_headshot_photo_asset).to eq(selected_asset)
    end

    it 'falls back to the linked photo profile preferred headshot when no template selection exists' do
      user = create(:user)
      photo_profile = PhotoProfile.create!(user:, name: 'Pat Kumar Photo Library', status: :active)
      resume = create(
        :resume,
        user:,
        photo_profile:,
        personal_details: {},
        contact_details: {
          'full_name' => 'Pat Kumar',
          'email' => 'pat@example.com',
          'website' => '',
          'linkedin' => '',
          'driving_licence' => ''
        }
      )

      expect(resume.personal_details_step_completed?).to eq(false)

      fallback_asset = create_ready_photo_asset(photo_profile:, filename: 'profile-headshot.png')

      expect(resume.selected_headshot_photo_asset).to eq(fallback_asset)
      expect(resume.personal_details_step_completed?).to eq(true)
    end
  end

  describe 'photo profile ownership' do
    it 'requires the selected photo profile to belong to the same user' do
      user = create(:user)
      other_user = create(:user)
      photo_profile = PhotoProfile.create!(user: other_user, name: 'Other User Photo Library', status: :active)
      resume = build(:resume, user:, photo_profile:)

      expect(resume).not_to be_valid
      expect(resume.errors[:photo_profile]).to include('must belong to the same user')
    end
  end
end
