require 'rails_helper'

RSpec.describe Resumes::PositionMover do
  describe '#call' do
    it 'moves a section to an explicit position' do
      resume = create(:resume)
      first_section = create(:section, resume:, position: 0, section_type: 'experience', title: 'Experience')
      second_section = create(:section, resume:, position: 1, section_type: 'education', title: 'Education')
      third_section = create(:section, resume:, position: 2, section_type: 'projects', title: 'Projects')

      described_class.new(record: first_section, position: 2).call

      expect(resume.sections.order(:position).pluck(:id)).to eq([second_section.id, third_section.id, first_section.id])
    end

    it 'moves an entry to an explicit position' do
      section = create(:section)
      first_entry = create(:entry, section:, position: 0, content: { 'title' => 'One' })
      second_entry = create(:entry, section:, position: 1, content: { 'title' => 'Two' })
      third_entry = create(:entry, section:, position: 2, content: { 'title' => 'Three' })

      described_class.new(record: third_entry, position: 0).call

      expect(section.entries.order(:position).pluck(:id)).to eq([third_entry.id, first_entry.id, second_entry.id])
    end
  end
end
