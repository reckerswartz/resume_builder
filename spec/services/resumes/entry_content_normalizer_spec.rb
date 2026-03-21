require 'rails_helper'

RSpec.describe Resumes::EntryContentNormalizer do
  def normalize(section_type:, params:)
    described_class.new(section_type: section_type, params: params).call
  end

  describe 'highlights normalization' do
    it 'splits highlights_text into an array of trimmed lines' do
      result = normalize(section_type: 'experience', params: {
        'highlights_text' => "Built APIs\n  Led team\n\nShipped features"
      })

      expect(result['highlights']).to eq(['Built APIs', 'Led team', 'Shipped features'])
      expect(result).not_to have_key('highlights_text')
    end

    it 'handles Windows-style line endings' do
      result = normalize(section_type: 'experience', params: {
        'highlights_text' => "Line one\r\nLine two"
      })

      expect(result['highlights']).to eq(['Line one', 'Line two'])
    end

    it 'preserves an existing highlights array when no highlights_text is present' do
      result = normalize(section_type: 'experience', params: {
        'highlights' => ['Already parsed']
      })

      expect(result['highlights']).to eq(['Already parsed'])
    end
  end

  describe 'experience date normalization' do
    it 'combines month and year into start_date and end_date' do
      result = normalize(section_type: 'experience', params: {
        'title' => 'Engineer',
        'start_month' => 'January',
        'start_year' => '2020',
        'end_month' => 'June',
        'end_year' => '2023'
      })

      expect(result['start_date']).to eq('January 2020')
      expect(result['end_date']).to eq('June 2023')
      expect(result).not_to have_key('start_month')
      expect(result).not_to have_key('start_year')
      expect(result).not_to have_key('end_month')
      expect(result).not_to have_key('end_year')
    end

    it 'sets end_date to Current when current_role is true' do
      result = normalize(section_type: 'experience', params: {
        'title' => 'Lead',
        'start_year' => '2022',
        'current_role' => 'true'
      })

      expect(result['end_date']).to eq('Current')
      expect(result['current_role']).to be(true)
    end

    it 'casts remote as a boolean' do
      result = normalize(section_type: 'experience', params: {
        'title' => 'Remote Dev',
        'remote' => '1'
      })

      expect(result['remote']).to be(true)
    end

    it 'handles year-only dates' do
      result = normalize(section_type: 'experience', params: {
        'title' => 'Intern',
        'start_year' => '2019',
        'end_year' => '2020'
      })

      expect(result['start_date']).to eq('2019')
      expect(result['end_date']).to eq('2020')
    end
  end

  describe 'skills normalization' do
    it 'defaults level to Advanced when blank' do
      result = normalize(section_type: 'skills', params: {
        'name' => 'Ruby'
      })

      expect(result['level']).to eq('Advanced')
    end

    it 'preserves an explicit level' do
      result = normalize(section_type: 'skills', params: {
        'name' => 'Ruby',
        'level' => 'Expert'
      })

      expect(result['level']).to eq('Expert')
    end
  end

  describe 'general normalization' do
    it 'strips blank values from params' do
      result = normalize(section_type: 'education', params: {
        'institution' => 'MIT',
        'degree' => '',
        'details' => nil
      })

      expect(result).to eq({ 'institution' => 'MIT' })
    end

    it 'deep-stringifies symbol keys' do
      result = normalize(section_type: 'education', params: {
        institution: 'Stanford'
      })

      expect(result).to eq({ 'institution' => 'Stanford' })
    end
  end
end
