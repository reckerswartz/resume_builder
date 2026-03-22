require 'rails_helper'

RSpec.describe Resumes::EntryFieldState do
  def build_state(entry:, section:)
    described_class.new(entry: entry, section: section)
  end

  describe '#field_value' do
    it 'returns the content value for a simple key' do
      section = create(:section, section_type: 'experience')
      entry = build(:entry, section: section, content: { 'title' => 'Engineer' })

      expect(build_state(entry: entry, section: section).field_value('title')).to eq('Engineer')
    end

    it 'joins highlights into a newline-separated string' do
      section = create(:section, section_type: 'experience')
      entry = build(:entry, section: section, content: { 'highlights' => [ 'Built APIs', 'Led team' ] })

      expect(build_state(entry: entry, section: section).field_value('highlights_text')).to eq("Built APIs\nLed team")
    end

    it 'extracts the year from a date string' do
      section = create(:section, section_type: 'experience')
      entry = build(:entry, section: section, content: { 'start_date' => 'January 2022' })

      expect(build_state(entry: entry, section: section).field_value('start_year')).to eq('2022')
      expect(build_state(entry: entry, section: section).field_value('start_month')).to eq('January')
    end

    it 'clears end date fields when current_role is true' do
      section = create(:section, section_type: 'experience')
      entry = build(:entry, section: section, content: { 'current_role' => true, 'end_date' => 'June 2025' })

      expect(build_state(entry: entry, section: section).field_value('end_month')).to eq('')
      expect(build_state(entry: entry, section: section).field_value('end_year')).to eq('')
    end

    it 'casts the current_role field as a boolean' do
      section = create(:section, section_type: 'experience')
      entry = build(:entry, section: section, content: { 'current_role' => 'true' })

      expect(build_state(entry: entry, section: section).field_value('current_role')).to be(true)
    end

    it 'returns an empty string for missing keys' do
      section = create(:section, section_type: 'experience')
      entry = build(:entry, section: section, content: {})

      expect(build_state(entry: entry, section: section).field_value('nonexistent')).to eq('')
    end
  end

  describe '#field_checked?' do
    it 'returns true for a truthy content value' do
      section = create(:section, section_type: 'experience')
      entry = build(:entry, section: section, content: { 'remote' => 'true' })

      expect(build_state(entry: entry, section: section).field_checked?('remote')).to be(true)
    end

    it 'returns false for a falsy content value' do
      section = create(:section, section_type: 'experience')
      entry = build(:entry, section: section, content: { 'remote' => 'false' })

      expect(build_state(entry: entry, section: section).field_checked?('remote')).to be(false)
    end
  end

  describe '#editor_title' do
    it 'returns the experience title when present' do
      section = create(:section, section_type: 'experience')
      entry = build(:entry, section: section, content: { 'title' => 'Engineering Manager' })

      expect(build_state(entry: entry, section: section).editor_title).to eq('Engineering Manager')
    end

    it 'falls back to the localized section entry title when content is blank' do
      section = create(:section, section_type: 'projects')
      entry = build(:entry, section: section, content: {})

      expect(build_state(entry: entry, section: section).editor_title).to eq('Projects entry')
    end

    it 'returns the degree for education entries' do
      section = create(:section, section_type: 'education')
      entry = build(:entry, section: section, content: { 'degree' => 'B.Sc.' })

      expect(build_state(entry: entry, section: section).editor_title).to eq('B.Sc.')
    end

    it 'returns the skill name for skills entries' do
      section = create(:section, section_type: 'skills')
      entry = build(:entry, section: section, content: { 'name' => 'Ruby' })

      expect(build_state(entry: entry, section: section).editor_title).to eq('Ruby')
    end
  end

  describe '#editor_metadata' do
    it 'joins organization and date range for experience entries' do
      section = create(:section, section_type: 'experience')
      entry = build(:entry, section: section, content: { 'organization' => 'Acme', 'start_date' => '2022', 'current_role' => true })

      expect(build_state(entry: entry, section: section).editor_metadata).to eq('Acme · 2022 - Present')
    end

    it 'returns the level for skills entries' do
      section = create(:section, section_type: 'skills')
      entry = build(:entry, section: section, content: { 'level' => 'Advanced' })

      expect(build_state(entry: entry, section: section).editor_metadata).to eq('Advanced')
    end

    it 'returns nil when no metadata is available' do
      section = create(:section, section_type: 'experience')
      entry = build(:entry, section: section, content: {})

      expect(build_state(entry: entry, section: section).editor_metadata).to be_nil
    end
  end

  describe '#editor_supporting_text' do
    it 'returns the summary for experience entries' do
      section = create(:section, section_type: 'experience')
      entry = build(:entry, section: section, content: { 'summary' => 'Led a Rails team.' })

      expect(build_state(entry: entry, section: section).editor_supporting_text).to eq('Led a Rails team.')
    end

    it 'falls back to the first highlight when summary is blank' do
      section = create(:section, section_type: 'experience')
      entry = build(:entry, section: section, content: { 'highlights' => [ 'Built APIs' ] })

      expect(build_state(entry: entry, section: section).editor_supporting_text).to eq('Built APIs')
    end

    it 'returns nil for skills entries' do
      section = create(:section, section_type: 'skills')
      entry = build(:entry, section: section, content: { 'name' => 'Ruby' })

      expect(build_state(entry: entry, section: section).editor_supporting_text).to be_nil
    end
  end
end
