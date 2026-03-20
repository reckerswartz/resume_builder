require 'rails_helper'

RSpec.describe Resumes::SummarySuggestionCatalog do
  describe '#call' do
    it 'returns search results for a requested role and exposes related roles' do
      resume = build(:resume, headline: 'Product Manager')

      state = described_class.new(resume: resume, query: 'product manager').call

      expect(state.query).to eq('Product Manager')
      expect(state.results.first).to include(
        role_key: 'product_manager',
        role_title: 'Product Manager',
        badge_label: 'Curated'
      )
      expect(state.results.first.fetch(:summary)).to include('cross-functional product decisions')
      expect(state.related_roles).to include(
        include(role_key: 'project_manager', title: 'Project Manager', query: 'Project Manager'),
        include(role_key: 'customer_success_manager', title: 'Customer Success Manager', query: 'Customer Success Manager')
      )
    end

    it 'prefers an early-career variant when the resume has early-career intake signals' do
      resume = build(
        :resume,
        headline: 'Software Engineer',
        intake_details: {
          'experience_level' => 'less_than_3_years',
          'student_status' => 'student'
        }
      )

      state = described_class.new(resume: resume, query: 'software engineer').call

      expect(state.results.first).to include(
        role_key: 'software_engineer',
        role_title: 'Software Engineer',
        badge_label: 'Recommended for early career'
      )
      expect(state.results.first.fetch(:summary)).to include('early-career software engineer')
    end
  end
end
