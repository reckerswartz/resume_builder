require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#ui_surface_classes' do
    it 'returns the dark shell surface classes for brand tone' do
      classes = helper.ui_surface_classes(tone: :brand, padding: :sm)

      expect(classes).to include('atelier-panel-dark')
      expect(classes).to include('p-5')
    end
  end

  describe '#ui_button_classes' do
    it 'returns disabled button classes when requested' do
      classes = helper.ui_button_classes(:disabled)

      expect(classes).to include('cursor-not-allowed')
      expect(classes).to include('bg-canvas-100/70')
      expect(classes).to include('text-slate-400')
    end
  end

  describe '#ui_selectable_card_classes' do
    it 'returns subtle unselected classes for compact cards' do
      classes = helper.ui_selectable_card_classes(selected: false, tone: :subtle)

      expect(classes).to include('rounded-[1.5rem]')
      expect(classes).to include('bg-canvas-100/88')
      expect(classes).to include('hover:bg-canvas-50')
      expect(classes).not_to include('bg-ink-950')
    end

    it 'returns selected classes for large cards' do
      classes = helper.ui_selectable_card_classes(selected: true, size: :lg)

      expect(classes).to include('rounded-[1.75rem]')
      expect(classes).to include('bg-ink-950')
      expect(classes).to include('text-white')
    end
  end

  describe '#ui_selectable_indicator_classes' do
    it 'returns dark indicator classes when selected' do
      expect(helper.ui_selectable_indicator_classes(selected: true)).to include('text-white')
    end

    it 'returns neutral indicator classes when unselected' do
      expect(helper.ui_selectable_indicator_classes(selected: false)).to include('text-slate-400')
    end
  end

  describe '#ui_selectable_supporting_text_classes' do
    it 'returns muted dark-surface text when selected' do
      expect(helper.ui_selectable_supporting_text_classes(selected: true)).to eq('text-white/72')
    end
  end

  describe '#ui_filter_chip_classes' do
    it 'returns active filter chip classes' do
      classes = helper.ui_filter_chip_classes(active: true)

      expect(classes).to include('rounded-full')
      expect(classes).to include('bg-ink-950')
      expect(classes).to include('text-white')
    end

    it 'returns inactive filter chip classes' do
      classes = helper.ui_filter_chip_classes(active: false)

      expect(classes).to include('bg-canvas-50/90')
      expect(classes).to include('text-ink-700')
      expect(classes).to include('hover:bg-canvas-50')
    end
  end
end
