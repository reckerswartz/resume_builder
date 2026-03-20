require 'rails_helper'

RSpec.describe Resumes::StartFlowState do
  let(:template) { create(:template) }
  let(:intake_details) { {} }
  let(:resume) { build(:resume, template:, template_id: template.id, intake_details:) }
  let(:step) { nil }

  subject(:start_flow_state) do
    described_class.new(resume: resume, step: step)
  end

  describe '#current_step' do
    it 'defaults to the experience step' do
      expect(start_flow_state.current_step).to eq('experience')
      expect(start_flow_state).to be_experience_step
      expect(start_flow_state).not_to be_setup_step
      expect(start_flow_state).not_to be_student_step
    end

    context 'when the setup step is requested with a supported experience level' do
      let(:step) { 'setup' }
      let(:intake_details) { { 'experience_level' => 'three_to_five_years' } }

      it 'uses the setup step' do
        expect(start_flow_state.current_step).to eq('setup')
        expect(start_flow_state).to be_setup_step
        expect(start_flow_state).not_to be_experience_step
      end
    end

    context 'when the setup step is requested without a supported experience level' do
      let(:step) { 'setup' }

      it 'falls back to the experience step' do
        expect(start_flow_state.current_step).to eq('experience')
        expect(start_flow_state).to be_experience_step
      end
    end

    context 'when the student step is requested with the junior experience level' do
      let(:step) { 'student' }
      let(:intake_details) { { 'experience_level' => 'less_than_3_years' } }

      it 'uses the student step' do
        expect(start_flow_state.current_step).to eq('student')
        expect(start_flow_state).to be_student_step
        expect(start_flow_state).not_to be_setup_step
      end
    end

    context 'when the student step is requested without the junior experience level' do
      let(:step) { 'student' }
      let(:intake_details) { { 'experience_level' => 'three_to_five_years' } }

      it 'falls back to the experience step' do
        expect(start_flow_state.current_step).to eq('experience')
        expect(start_flow_state).to be_experience_step
      end
    end
  end

  describe '#experience_options' do
    it 'exposes the hosted-inspired experience options in order' do
      expect(start_flow_state.experience_options).to eq(
        [
          { label: 'No Experience', value: 'no_experience' },
          { label: 'Less than 3 years', value: 'less_than_3_years' },
          { label: '3-5 Years', value: 'three_to_five_years' },
          { label: '5-10 Years', value: 'five_to_ten_years' },
          { label: '10+ Years', value: 'ten_plus_years' }
        ]
      )
    end
  end

  describe '#student_options' do
    it 'exposes yes and no choices for the student follow-up' do
      expect(start_flow_state.student_options).to eq(
        [
          { label: 'Yes', value: 'student' },
          { label: 'No', value: 'not_student' }
        ]
      )
    end
  end

  describe '#selected_experience_level' do
    let(:intake_details) { { 'experience_level' => 'three_to_five_years' } }

    it 'returns the normalized experience level from the resume draft' do
      expect(start_flow_state.selected_experience_level).to eq('three_to_five_years')
      expect(start_flow_state.selected_experience_option.fetch(:label)).to eq('3-5 Years')
    end
  end

  describe '#selected_student_status' do
    let(:intake_details) do
      {
        'experience_level' => 'less_than_3_years',
        'student_status' => 'student'
      }
    end

    it 'returns the normalized student status from the resume draft' do
      expect(start_flow_state.selected_student_status).to eq('student')
    end
  end

  describe '#selected_template_id' do
    it 'keeps the currently selected template id available for step carry-through' do
      expect(start_flow_state.selected_template_id).to eq(template.id)
    end
  end

  describe '#next_step_for_experience' do
    it 'routes the junior experience selection to the student follow-up' do
      expect(start_flow_state.next_step_for_experience('less_than_3_years')).to eq('student')
    end

    it 'routes other experience selections directly to setup' do
      expect(start_flow_state.next_step_for_experience('three_to_five_years')).to eq('setup')
    end
  end
end
