require 'rails_helper'

RSpec.describe Ui::ReportRowComponent, type: :component do
  describe '#linked?' do
    it 'returns true when a path is provided' do
      component = described_class.new(title: 'Template A', path: '/admin/templates/1')

      expect(component).to be_linked
    end

    it 'returns false when no path is provided' do
      component = described_class.new(title: 'Template A')

      expect(component).not_to be_linked
    end
  end

  describe '#wrapper_classes' do
    it 'includes hover state classes for linked rows' do
      component = described_class.new(title: 'Template A', path: '/admin/templates/1')

      expect(component.wrapper_classes).to include('hover:border-aqua-200/80')
      expect(component.wrapper_classes).to include('hover:bg-canvas-50')
    end

    it 'omits hover state classes for non-linked rows' do
      component = described_class.new(title: 'Template A')

      expect(component.wrapper_classes).to include('bg-canvas-50/92')
      expect(component.wrapper_classes).not_to include('hover:border-aqua-200/80')
    end

    it 'always includes the shared base layout classes' do
      component = described_class.new(title: 'Row')

      expect(component.wrapper_classes).to include('flex items-center justify-between')
      expect(component.wrapper_classes).to include('rounded-2xl')
      expect(component.wrapper_classes).to include('border-canvas-200/80')
    end
  end

  describe '#badges' do
    it 'normalizes a single legacy badge into the badges array' do
      component = described_class.new(title: 'Row', badge: 'Live', badge_classes: 'text-emerald-700')

      expect(component.badges).to eq([ { label: 'Live', classes: 'text-emerald-700' } ])
    end

    it 'normalizes hash-style badges from an array' do
      component = described_class.new(title: 'Row', badges: [ { 'label' => 'Draft' }, { 'label' => 'Hidden' } ])

      expect(component.badges).to eq([ { label: 'Draft' }, { label: 'Hidden' } ])
    end

    it 'prepends the legacy badge before array badges' do
      component = described_class.new(title: 'Row', badge: 'Primary', badge_classes: 'text-blue-700', badges: [ { label: 'Active' } ])

      expect(component.badges.first).to eq({ label: 'Primary', classes: 'text-blue-700' })
      expect(component.badges.last).to eq({ label: 'Active' })
    end

    it 'returns an empty array when no badges are provided' do
      component = described_class.new(title: 'Row')

      expect(component.badges).to eq([])
    end
  end

  describe 'rendering' do
    it 'renders the title in a paragraph element' do
      render_inline(described_class.new(title: 'Modern template'))

      expect(rendered_content).to include('Modern template')
      expect(rendered_content).to include('text-ink-950')
    end

    it 'renders the subtitle when provided' do
      render_inline(described_class.new(title: 'Modern', subtitle: 'Last updated 2 days ago'))

      expect(rendered_content).to include('Last updated 2 days ago')
      expect(rendered_content).to include('text-ink-700/65')
    end

    it 'omits the subtitle paragraph when not provided' do
      render_inline(described_class.new(title: 'Modern'))

      expect(rendered_content).not_to include('text-ink-700/65')
    end

    it 'renders as a link when a path is present' do
      render_inline(described_class.new(title: 'Classic', path: '/templates/classic'))

      expect(rendered_content).to include('<a')
      expect(rendered_content).to include('/templates/classic')
    end

    it 'renders as a div when no path is present' do
      render_inline(described_class.new(title: 'Classic'))

      expect(rendered_content).not_to include('<a')
      expect(rendered_content).to include('<div')
    end

    it 'renders badge spans when badges are present' do
      render_inline(described_class.new(title: 'Row', badges: [ { label: 'Active' } ]))

      expect(rendered_content).to include('Active')
      expect(rendered_content).to include('rounded-full')
    end
  end
end
