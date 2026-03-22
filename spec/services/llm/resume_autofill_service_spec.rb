require 'rails_helper'
require 'zip'

RSpec.describe Llm::ResumeAutofillService do
  let(:user) { create(:user) }
  let(:resume) do
    create(
      :resume,
      user:,
      source_mode: 'paste',
      source_text: <<~TEXT
        Pat Kumar
        Senior Software Engineer
        pat@example.com | +91 98765 43210 | Pune, India 411001
        linkedin.com/in/patkumar | https://patkumar.dev

        Summary
        Product-minded Rails engineer with 7+ years building workflow tools.

        Experience
        Senior Software Engineer, Acme Corp, Pune
        Jan 2021 - Present
        Led resume builder delivery across Rails and Hotwire.
        - Improved completion rate by 18%
        - Reduced support tickets by 24%

        Education
        State University
        B.Tech Computer Science
        2014 - 2018

        Skills
        Ruby on Rails
        Hotwire
      TEXT
    )
  end
  let!(:experience_section) { create(:section, resume:, section_type: 'experience', title: 'Experience', position: 0) }
  let!(:education_section) { create(:section, resume:, section_type: 'education', title: 'Education', position: 1) }
  let!(:skills_section) { create(:section, resume:, section_type: 'skills', title: 'Skills', position: 2) }
  let!(:starter_entry) { create(:entry, section: experience_section, content: { 'title' => 'Starter Role', 'organization' => 'Starter Org', 'highlights' => [ 'Starter highlight' ] }) }
  let(:llm_provider) { create(:llm_provider) }
  let(:generation_model) { create(:llm_model, llm_provider:, identifier: 'autofill-generator') }
  let(:verification_model) { create(:llm_model, llm_provider:, identifier: 'autofill-verifier') }
  let!(:generation_assignment) { create(:llm_model_assignment, llm_model: generation_model, role: 'text_generation') }
  let!(:verification_assignment) { create(:llm_model_assignment, llm_model: verification_model, role: 'text_verification') }
  let(:provider_client_class) do
    Class.new do
      def initialize(responses)
        @responses = responses
      end

      def generate_text(model:, prompt:)
        @responses.fetch(model.identifier)
      end
    end
  end
  let(:provider_client) do
    provider_client_class.new(
      generation_model.identifier => {
        content: <<~JSON,
          {
            "resume": {
              "title": "Pat Kumar Resume",
              "headline": "Senior Software Engineer",
              "summary": "Product-minded Rails engineer with 7+ years building workflow tools.",
              "contact_details": {
                "full_name": "Pat Kumar",
                "email": "pat@example.com",
                "phone": "+91 98765 43210",
                "city": "Pune",
                "country": "India",
                "pin_code": "411001",
                "website": "https://patkumar.dev",
                "linkedin": "https://linkedin.com/in/patkumar"
              }
            },
            "sections": {
              "experience": [
                {
                  "title": "Senior Software Engineer",
                  "organization": "Acme Corp",
                  "location": "Pune",
                  "start_date": "Jan 2021",
                  "end_date": "",
                  "current_role": true,
                  "summary": "Led resume builder delivery across Rails and Hotwire.",
                  "highlights": ["Improved completion rate by 18%"]
                }
              ],
              "education": [
                {
                  "institution": "State University",
                  "degree": "B.Tech Computer Science",
                  "start_date": "2014",
                  "end_date": "2018",
                  "details": ""
                }
              ],
              "skills": [
                {
                  "name": "Ruby on Rails",
                  "level": "Advanced"
                }
              ]
            }
          }
        JSON
        token_usage: { 'input_tokens' => 24, 'output_tokens' => 18 },
        metadata: { 'source' => 'generation-spec' }
      },
      verification_model.identifier => {
        content: <<~JSON,
          {
            "resume": {
              "contact_details": {
                "linkedin": "https://linkedin.com/in/patkumar"
              }
            },
            "sections": {
              "experience": [
                {
                  "title": "Senior Software Engineer",
                  "organization": "Acme Corp",
                  "start_date": "Jan 2021",
                  "highlights": ["Reduced support tickets by 24%"]
                }
              ],
              "education": [],
              "skills": [
                {
                  "name": "Hotwire",
                  "level": "Advanced"
                }
              ]
            }
          }
        JSON
        token_usage: { 'input_tokens' => 12, 'output_tokens' => 9 },
        metadata: { 'source' => 'verification-spec' }
      }
    )
  end

  before do
    PlatformSetting.current.update!(
      feature_flags: {
        'llm_access' => true,
        'resume_suggestions' => true,
        'autofill_content' => true
      },
      preferences: PlatformSetting.current.preferences
    )

    allow(Llm::ClientFactory).to receive(:build).and_return(provider_client)
  end

  describe '#call' do
    it 'fills the resume from pasted text, merges verification details, and logs interactions' do
      result = described_class.new(user:, resume:).call

      expect(result).to be_success
      expect(result.resume.reload.title).to eq('Pat Kumar Resume')
      expect(result.resume.headline).to eq('Senior Software Engineer')
      expect(result.resume.summary).to eq('Product-minded Rails engineer with 7+ years building workflow tools.')
      expect(result.resume.contact_details).to include(
        'full_name' => 'Pat Kumar',
        'email' => 'pat@example.com',
        'city' => 'Pune',
        'country' => 'India',
        'pin_code' => '411001'
      )

      experience_entry = experience_section.reload.entries.first
      expect(experience_section.entries.count).to eq(1)
      expect(experience_entry.content).to include(
        'title' => 'Senior Software Engineer',
        'organization' => 'Acme Corp',
        'current_role' => true,
        'end_date' => 'Present'
      )
      expect(experience_entry.highlights).to eq([
        'Improved completion rate by 18%',
        'Reduced support tickets by 24%'
      ])

      expect(education_section.reload.entries.first.content).to include(
        'institution' => 'State University',
        'degree' => 'B.Tech Computer Science'
      )
      expect(skills_section.reload.entries.pluck(:content)).to contain_exactly(
        include('name' => 'Ruby on Rails', 'level' => 'Advanced'),
        include('name' => 'Hotwire', 'level' => 'Advanced')
      )

      expect(result.interactions.size).to eq(2)
      expect(result.interactions.map(&:role)).to contain_exactly('text_generation', 'text_verification')
      expect(result.interactions.map(&:llm_model)).to contain_exactly(generation_model, verification_model)
    end

    it 'fills the resume from a supported DOCX uploaded source document' do
      resume.update!(source_mode: 'upload', source_text: '')
      docx_buffer = Zip::OutputStream.write_buffer do |zip|
        zip.put_next_entry('word/document.xml')
        zip.write <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
            <w:body>
              <w:p><w:r><w:t>Pat Kumar</w:t></w:r></w:p>
              <w:p><w:r><w:t>Senior Software Engineer</w:t></w:r></w:p>
              <w:p><w:r><w:t>pat@example.com</w:t></w:r></w:p>
            </w:body>
          </w:document>
        XML
      end

      resume.source_document.attach(
        io: StringIO.new(docx_buffer.string),
        filename: 'resume.docx',
        content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      )

      result = described_class.new(user:, resume:).call

      expect(result).to be_success
      expect(result.resume.reload.title).to eq('Pat Kumar Resume')
      expect(result.interactions.size).to eq(2)
      expect(result.interactions.map { |interaction| interaction.metadata['source_kind'] }.uniq).to eq([ 'uploaded_document' ])
      expect(result.interactions.map { |interaction| interaction.metadata['source_content_type'] }.uniq).to eq([ 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' ])
    end

    it 'fills the resume from a supported PDF uploaded source document' do
      resume.update!(source_mode: 'upload', source_text: '')
      resume.source_document.attach(
        io: StringIO.new('%PDF-1.7 sample'),
        filename: 'resume.pdf',
        content_type: 'application/pdf'
      )
      allow_any_instance_of(Resumes::PdfTextExtractor).to receive(:call).and_return("Pat Kumar\nSenior Software Engineer\npat@example.com")

      result = described_class.new(user:, resume:).call

      expect(result).to be_success
      expect(result.resume.reload.title).to eq('Pat Kumar Resume')
      expect(result.interactions.size).to eq(2)
      expect(result.interactions.map { |interaction| interaction.metadata['source_kind'] }.uniq).to eq([ 'uploaded_document' ])
      expect(result.interactions.map { |interaction| interaction.metadata['source_content_type'] }.uniq).to eq([ 'application/pdf' ])
    end

    it 'returns the localized disabled error when autofill is unavailable' do
      PlatformSetting.current.update!(
        feature_flags: {
          'llm_access' => true,
          'resume_suggestions' => true,
          'autofill_content' => false
        },
        preferences: PlatformSetting.current.preferences
      )

      result = described_class.new(user:, resume:).call

      expect(result).not_to be_success
      expect(result.error_message).to eq(I18n.t('resumes.resume_autofill_service.disabled'))
      expect(result.interactions.size).to eq(1)
      expect(result.interactions.first.error_message).to eq(I18n.t('resumes.resume_autofill_service.disabled'))
    end

    it 'returns the localized no-models error when no text generation model is assigned' do
      allow(LlmModelAssignment).to receive(:ready_models_for).and_call_original
      allow(LlmModelAssignment).to receive(:ready_models_for).with('text_generation').and_return([])

      result = described_class.new(user:, resume:).call

      expect(result).not_to be_success
      expect(result.error_message).to eq(I18n.t('resumes.resume_autofill_service.no_models'))
      expect(result.interactions.size).to eq(1)
      expect(result.interactions.first.error_message).to eq(I18n.t('resumes.resume_autofill_service.no_models'))
    end

    it 'returns the localized invalid-payload error when the generation model returns no structured resume data' do
      invalid_payload_client = provider_client_class.new(
        generation_model.identifier => {
          content: '{}',
          token_usage: { 'input_tokens' => 12, 'output_tokens' => 3 },
          metadata: { 'source' => 'invalid-payload-spec' }
        },
        verification_model.identifier => {
          content: '{}',
          token_usage: { 'input_tokens' => 8, 'output_tokens' => 2 },
          metadata: { 'source' => 'invalid-payload-spec' }
        }
      )
      allow(Llm::ClientFactory).to receive(:build).and_return(invalid_payload_client)

      result = described_class.new(user:, resume:).call

      expect(result).not_to be_success
      expect(result.error_message).to eq(I18n.t('resumes.resume_autofill_service.invalid_payload'))
      expect(result.interactions.size).to eq(1)
    end
  end
end
