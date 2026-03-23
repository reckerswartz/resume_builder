require 'rails_helper'

RSpec.describe Ui::MetricCardComponent, type: :component do
  describe '#hero?' do
    it 'returns true when tone is hero' do
      component = described_class.new(label: 'Total', value: '42', description: 'All time', tone: :hero)

      expect(component).to be_hero
    end

    it 'returns false for the default tone' do
      component = described_class.new(label: 'Total', value: '42', description: 'All time')

      expect(component).not_to be_hero
    end

    it 'handles string tone values by casting to symbol' do
      component = described_class.new(label: 'Total', value: '42', description: 'All time', tone: 'hero')

      expect(component).to be_hero
    end
  end

  describe 'rendering with default tone' do
    it 'renders the label, value, and description with default surface classes' do
      render_inline(described_class.new(label: 'Templates', value: '12', description: 'Active in gallery'))

      expect(rendered_content).to include('Templates')
      expect(rendered_content).to include('12')
      expect(rendered_content).to include('Active in gallery')
      expect(rendered_content).to include('bg-canvas-50/92')
      expect(rendered_content).to include('text-ink-950')
      expect(rendered_content).to include('text-2xl')
    end

    it 'uses the muted label color for default tone' do
      render_inline(described_class.new(label: 'Drafts', value: '3', description: 'In progress'))

      expect(rendered_content).to include('text-ink-700/60')
    end
  end

  describe 'rendering with hero tone' do
    it 'renders with hero surface classes and white text' do
      render_inline(described_class.new(label: 'Checks', value: '7', description: 'Passed this week', tone: :hero))

      expect(rendered_content).to include('Checks')
      expect(rendered_content).to include('7')
      expect(rendered_content).to include('Passed this week')
      expect(rendered_content).to include('bg-white/6')
      expect(rendered_content).to include('text-white')
      expect(rendered_content).to include('text-3xl')
    end

    it 'uses the translucent label color for hero tone' do
      render_inline(described_class.new(label: 'Score', value: '98%', description: 'Overall rating', tone: :hero))

      expect(rendered_content).to include('text-white/60')
    end
  end
end
