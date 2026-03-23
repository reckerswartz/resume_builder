require 'rails_helper'

RSpec.describe Ui::CodeBlockComponent, type: :component do
  describe '#title_classes' do
    it 'uses default ink title color for the default tone' do
      component = described_class.new(title: 'Output', body: '{}')

      expect(component.title_classes).to include('text-ink-950')
      expect(component.title_classes).to include('text-xl')
    end

    it 'uses danger title color for the danger tone' do
      component = described_class.new(title: 'Error', body: 'stack trace', tone: :danger)

      expect(component.title_classes).to include('text-rose-900')
    end
  end

  describe '#description_classes' do
    it 'uses default ink description color for the default tone' do
      component = described_class.new(title: 'Output', body: '{}')

      expect(component.description_classes).to include('text-ink-700/80')
      expect(component.description_classes).to include('mt-2')
    end

    it 'uses danger description color for the danger tone' do
      component = described_class.new(title: 'Error', body: 'stack trace', tone: :danger)

      expect(component.description_classes).to include('text-rose-700')
    end
  end

  describe '#block_classes' do
    it 'uses pre-formatted whitespace by default' do
      component = described_class.new(title: 'Output', body: '{}')

      expect(component.block_classes).to include('whitespace-pre')
      expect(component.block_classes).not_to include('whitespace-pre-wrap')
      expect(component.block_classes).to include('bg-ink-950')
      expect(component.block_classes).to include('rounded-2xl')
    end

    it 'enables word wrapping when wrap is true' do
      component = described_class.new(title: 'Wrapped', body: 'long text', wrap: true)

      expect(component.block_classes).to include('whitespace-pre-wrap')
      expect(component.block_classes).to include('break-words')
    end
  end

  describe 'rendering' do
    it 'renders the title and body in a code block' do
      render_inline(described_class.new(title: 'JSON payload', body: '{ "key": "value" }'))

      expect(rendered_content).to include('JSON payload')
      expect(rendered_content).to include('{ &quot;key&quot;: &quot;value&quot; }')
      expect(rendered_content).to include('<pre')
      expect(rendered_content).to include('<h2')
    end

    it 'renders the optional description when provided' do
      render_inline(described_class.new(title: 'Trace', body: 'line 1', description: 'Full stack trace from the worker'))

      expect(rendered_content).to include('Full stack trace from the worker')
    end

    it 'omits the description paragraph when not provided' do
      render_inline(described_class.new(title: 'Trace', body: 'line 1'))

      expect(rendered_content).not_to include('text-ink-700/80')
    end
  end
end
