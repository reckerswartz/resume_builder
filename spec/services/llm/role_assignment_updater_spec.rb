require 'rails_helper'

RSpec.describe Llm::RoleAssignmentUpdater do
  def build_updater(role_model_ids)
    described_class.new(role_model_ids: role_model_ids)
  end

  let(:provider) { create(:llm_provider) }

  describe '#call' do
    context 'successful assignment' do
      it 'assigns a text-capable model to text_generation' do
        model = create(:llm_model, llm_provider: provider, supports_text: true)

        result = build_updater('text_generation' => [model.id]).call

        expect(result).to be_success
        expect(LlmModelAssignment.for_role('text_generation').map(&:llm_model_id)).to eq([model.id])
      end

      it 'assigns a vision-capable model to vision_generation' do
        model = create(:llm_model, :vision_capable, llm_provider: provider)

        result = build_updater('vision_generation' => [model.id]).call

        expect(result).to be_success
        expect(LlmModelAssignment.for_role('vision_generation').map(&:llm_model_id)).to eq([model.id])
      end

      it 'clears existing assignments when given an empty array for a role' do
        model = create(:llm_model, llm_provider: provider, supports_text: true)
        create(:llm_model_assignment, llm_model: model, role: 'text_generation')

        result = build_updater('text_generation' => []).call

        expect(result).to be_success
        expect(LlmModelAssignment.for_role('text_generation')).to be_empty
      end

      it 'replaces existing assignments with new ones' do
        old_model = create(:llm_model, llm_provider: provider, supports_text: true)
        new_model = create(:llm_model, llm_provider: provider, supports_text: true)
        create(:llm_model_assignment, llm_model: old_model, role: 'text_verification')

        result = build_updater('text_verification' => [new_model.id]).call

        expect(result).to be_success
        expect(LlmModelAssignment.for_role('text_verification').map(&:llm_model_id)).to eq([new_model.id])
      end

      it 'preserves position ordering for verification roles with multiple models' do
        model_a = create(:llm_model, llm_provider: provider, supports_text: true)
        model_b = create(:llm_model, llm_provider: provider, supports_text: true)

        result = build_updater('text_verification' => [model_b.id, model_a.id]).call

        expect(result).to be_success
        assignments = LlmModelAssignment.for_role('text_verification')
        expect(assignments.map(&:llm_model_id)).to eq([model_b.id, model_a.id])
        expect(assignments.map(&:position)).to eq([0, 1])
      end
    end

    context 'validation failures' do
      it 'rejects multiple models for a generation role' do
        model_a = create(:llm_model, llm_provider: provider, supports_text: true)
        model_b = create(:llm_model, llm_provider: provider, supports_text: true)

        result = build_updater('text_generation' => [model_a.id, model_b.id]).call

        expect(result).not_to be_success
        expect(result.errors).to include(a_string_matching(/can only have one primary model/))
      end

      it 'rejects an unknown model ID' do
        result = build_updater('text_generation' => [999_999]).call

        expect(result).not_to be_success
        expect(result.errors).to include(a_string_matching(/unknown model/))
      end

      it 'rejects a model that does not support the assigned role' do
        text_only_model = create(:llm_model, llm_provider: provider, supports_text: true, supports_vision: false)

        result = build_updater('vision_generation' => [text_only_model.id]).call

        expect(result).not_to be_success
        expect(result.errors).to include(a_string_matching(/does not support/))
      end
    end

    context 'transactional safety' do
      it 'does not persist partial changes when a later role fails validation at the DB level' do
        text_model = create(:llm_model, llm_provider: provider, supports_text: true)

        expect do
          build_updater(
            'text_generation' => [text_model.id],
            'vision_generation' => [text_model.id]
          ).call
        end.not_to change(LlmModelAssignment, :count)
      end
    end
  end
end
