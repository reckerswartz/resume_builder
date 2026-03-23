require 'rails_helper'

RSpec.describe TemplatePolicy do
  subject(:policy) { described_class.new(user, template) }

  let(:regular_user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:template) { create(:template) }

  describe 'permissions for an authenticated user' do
    let(:user) { regular_user }

    it { is_expected.to be_index }
    it { is_expected.to be_show }
    it { is_expected.to be_apply_to_resume }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
  end

  describe 'permissions for an admin' do
    let(:user) { admin }

    it { is_expected.to be_index }
    it { is_expected.to be_show }
    it { is_expected.to be_apply_to_resume }
    it { is_expected.to be_create }
    it { is_expected.to be_update }
    it { is_expected.to be_destroy }
  end

  describe 'permissions for a guest (nil user)' do
    let(:user) { nil }

    it { is_expected.to be_index }
    it { is_expected.to be_show }
    it { is_expected.not_to be_apply_to_resume }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
  end

  describe TemplatePolicy::Scope do
    it 'returns only active templates for a regular user' do
      active_template = create(:template, active: true)
      inactive_template = create(:template, active: false)

      resolved = described_class.new(regular_user, Template).resolve

      expect(resolved).to include(active_template)
      expect(resolved).not_to include(inactive_template)
    end

    it 'falls back to all templates when no active templates exist' do
      inactive_template = create(:template, active: false)

      resolved = described_class.new(regular_user, Template).resolve

      expect(resolved).to include(inactive_template)
    end

    it 'returns all templates for an admin' do
      active_template = create(:template, active: true)
      inactive_template = create(:template, active: false)

      resolved = described_class.new(admin, Template).resolve

      expect(resolved).to include(active_template, inactive_template)
    end

    it 'returns no templates for a nil user' do
      create(:template)

      resolved = described_class.new(nil, Template).resolve

      expect(resolved.count).to eq(0)
    end
  end
end
