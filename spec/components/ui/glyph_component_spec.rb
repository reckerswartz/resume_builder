require 'rails_helper'

RSpec.describe Ui::GlyphComponent, type: :component do
  describe 'size classes' do
    it 'uses the default medium sizing' do
      component = described_class.new(name: :spark)

      render_inline(component)

      expect(rendered_content).to include('h-10 w-10')
      expect(rendered_content).to include('h-5 w-5')
    end

    it 'uses extra-small sizing for the xs variant' do
      component = described_class.new(name: :spark, size: :xs)

      render_inline(component)

      expect(rendered_content).to include('h-4 w-4')
    end

    it 'uses small sizing for the sm variant' do
      component = described_class.new(name: :spark, size: :sm)

      render_inline(component)

      expect(rendered_content).to include('h-9 w-9')
    end

    it 'uses large sizing with a larger rounded corner' do
      component = described_class.new(name: :spark, size: :lg)

      render_inline(component)

      expect(rendered_content).to include('h-12 w-12')
      expect(rendered_content).to include('rounded-[1.2rem]')
      expect(rendered_content).to include('h-6 w-6')
    end
  end

  describe 'tone classes' do
    it 'applies the default subtle surface tone' do
      component = described_class.new(name: :layers)

      render_inline(component)

      expect(rendered_content).to include('bg-canvas-50/92')
      expect(rendered_content).to include('text-ink-950')
    end

    it 'applies the minimal tone with current color' do
      component = described_class.new(name: :layers, tone: :minimal)

      render_inline(component)

      expect(rendered_content).to include('text-current')
    end

    it 'applies the soft surface tone' do
      component = described_class.new(name: :layers, tone: :soft)

      render_inline(component)

      expect(rendered_content).to include('bg-canvas-100/88')
      expect(rendered_content).to include('border-mist-200/80')
    end

    it 'applies the dark surface tone' do
      component = described_class.new(name: :layers, tone: :dark)

      render_inline(component)

      expect(rendered_content).to include('bg-ink-950')
      expect(rendered_content).to include('text-white')
    end

    it 'applies the hero surface tone' do
      component = described_class.new(name: :layers, tone: :hero)

      render_inline(component)

      expect(rendered_content).to include('bg-white/8')
      expect(rendered_content).to include('text-white')
    end
  end

  describe 'SVG rendering' do
    it 'renders an SVG element with the correct viewBox and stroke attributes' do
      render_inline(described_class.new(name: :spark))

      expect(rendered_content).to include('<svg')
      expect(rendered_content).to include('viewBox="0 0 24 24"')
      expect(rendered_content).to include('fill="none"')
      expect(rendered_content).to include('stroke="currentColor"')
    end

    it 'renders path elements from the icon definition' do
      render_inline(described_class.new(name: :shield))

      expect(rendered_content).to include('<path')
    end

    it 'marks the wrapper as aria-hidden' do
      render_inline(described_class.new(name: :preview))

      expect(rendered_content).to include('aria-hidden="true"')
    end

    it 'renders all registered icon names without raising' do
      Ui::GlyphComponent::ICONS.each_key do |icon_name|
        expect { render_inline(described_class.new(name: icon_name)) }.not_to raise_error
      end
    end
  end
end
