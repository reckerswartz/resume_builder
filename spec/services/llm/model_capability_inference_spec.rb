require 'rails_helper'

RSpec.describe Llm::ModelCapabilityInference do
  describe '#call' do
    it 'classifies embedding models without enabling text or vision workflow roles' do
      result = described_class.new(
        identifier: 'nvidia/llama-3.2-nemoretriever-1b-vlm-embed-v1',
        raw_attributes: {
          'owned_by' => 'nvidia',
          'input_modalities' => ['image', 'text'],
          'output_modalities' => ['embedding']
        }
      ).call

      expect(result).to include(
        'model_type' => 'embedding',
        'supports_text' => false,
        'supports_vision' => false
      )
    end

    it 'classifies multimodal models as both text and vision capable' do
      result = described_class.new(
        identifier: 'microsoft/phi-4-multimodal-instruct',
        raw_attributes: {
          'owned_by' => 'microsoft',
          'input_modalities' => ['text', 'image'],
          'output_modalities' => ['text']
        }
      ).call

      expect(result).to include(
        'model_type' => 'multimodal',
        'supports_text' => true,
        'supports_vision' => true
      )
    end
  end
end
