require 'rails_helper'

RSpec.describe Resumes::SeedProfileCatalog do
  describe '.all' do
    it 'returns a non-empty array of profile hashes' do
      profiles = described_class.all

      expect(profiles).to be_an(Array)
      expect(profiles).not_to be_empty
    end

    it 'provides unique keys across all profiles' do
      keys = described_class.all.map { |p| p.fetch(:key) }

      expect(keys).to eq(keys.uniq)
    end

    it 'includes required fields for every profile' do
      required_keys = %i[key label primary_title focus industry career_years skills education sections_enabled]

      described_class.all.each do |profile|
        required_keys.each do |required_key|
          expect(profile).to have_key(required_key), "Profile #{profile[:key]} is missing :#{required_key}"
        end
      end
    end

    it 'includes at least 5 skills per profile' do
      described_class.all.each do |profile|
        expect(profile.fetch(:skills).size).to be >= 5, "Profile #{profile[:key]} has fewer than 5 skills"
      end
    end

    it 'includes at least one education entry per profile' do
      described_class.all.each do |profile|
        expect(profile.fetch(:education)).not_to be_empty, "Profile #{profile[:key]} has no education entries"
      end
    end
  end

  describe '.keys' do
    it 'returns all profile keys as strings' do
      keys = described_class.keys

      expect(keys).to all(be_a(String))
      expect(keys.size).to eq(described_class.profile_count)
    end
  end

  describe '.find' do
    it 'returns the matching profile by key' do
      first_key = described_class.keys.first
      profile = described_class.find(first_key)

      expect(profile.fetch(:key)).to eq(first_key)
    end

    it 'raises KeyError for an unknown profile key' do
      expect { described_class.find('nonexistent') }.to raise_error(KeyError, /Unknown seed profile/)
    end
  end

  describe '.sections_for' do
    let(:profile) { described_class.all.first }

    it 'returns all enabled sections in full mode' do
      sections = described_class.sections_for(profile, mode: :full)

      expect(sections).to eq(profile.fetch(:sections_enabled))
    end

    it 'returns only core sections in minimal mode' do
      sections = described_class.sections_for(profile, mode: :minimal)

      expect(sections).to all(be_in(%w[experience education skills]))
    end
  end
end
