require 'rails_helper'

RSpec.describe Ui::WidgetCardComponent, type: :component do
  it 'renders the eyebrow and title inside an article' do
    render_inline(described_class.new(eyebrow: 'Stats', title: 'Total views'))

    expect(rendered_content).to include('<article')
    expect(rendered_content).to include('Stats')
    expect(rendered_content).to include('Total views')
  end

  it 'renders the description when provided' do
    render_inline(described_class.new(eyebrow: 'Stats', title: 'Views', description: 'Last 30 days'))

    expect(rendered_content).to include('Last 30 days')
    expect(rendered_content).to include('text-sm')
  end

  it 'omits the description paragraph when not provided' do
    render_inline(described_class.new(eyebrow: 'Stats', title: 'Views'))

    expect(rendered_content).not_to include('mt-1 text-sm')
  end

  it 'renders the badge when provided' do
    render_inline(described_class.new(eyebrow: 'Stats', title: 'Views', badge: '+12%'))

    expect(rendered_content).to include('+12%')
  end

  it 'omits the badge span when not provided' do
    html = render_inline(described_class.new(eyebrow: 'Stats', title: 'Views')).to_html

    expect(html).not_to include('resolved_badge_classes')
  end

  it 'renders block content with body spacing' do
    render_inline(described_class.new(eyebrow: 'Stats', title: 'Views')) { 'Chart here' }

    expect(rendered_content).to include('Chart here')
    expect(rendered_content).to include('mt-3')
  end

  it 'uses mt-4 body spacing when description is present' do
    component = described_class.new(eyebrow: 'Stats', title: 'Views', description: 'Details')

    expect(component.body_spacing_classes).to eq('mt-4')
  end

  it 'uses mt-3 body spacing when description is absent' do
    component = described_class.new(eyebrow: 'Stats', title: 'Views')

    expect(component.body_spacing_classes).to eq('mt-3')
  end

  it 'uses subtle tone classes by default' do
    component = described_class.new(eyebrow: 'Stats', title: 'Views')

    expect(component.wrapper_classes).to include('border-mist-200/80')
    expect(component.wrapper_classes).to include('bg-canvas-100/88')
    expect(component.eyebrow_classes).to include('text-ink-700/70')
    expect(component.title_classes).to include('text-ink-950')
    expect(component.description_classes).to include('text-ink-700/80')
  end

  it 'uses dark tone classes when tone is dark' do
    component = described_class.new(eyebrow: 'Stats', title: 'Views', tone: :dark)

    expect(component.wrapper_classes).to include('border-white/10')
    expect(component.wrapper_classes).to include('bg-ink-950/90')
    expect(component.eyebrow_classes).to eq('text-white/60')
    expect(component.title_classes).to include('text-white')
    expect(component.description_classes).to eq('text-white/70')
  end

  it 'uses default tone classes when tone is :default' do
    component = described_class.new(eyebrow: 'Stats', title: 'Views', tone: :default)

    expect(component.wrapper_classes).to include('border-canvas-200/80')
    expect(component.wrapper_classes).to include('bg-canvas-50/92')
    expect(component.wrapper_classes).to include('shadow-[0_18px_40px_rgba(15,23,42,0.08)]')
  end

  it 'uses success tone classes when tone is :success' do
    component = described_class.new(eyebrow: 'Stats', title: 'Views', tone: :success)

    expect(component.wrapper_classes).to include('border-emerald-200/80')
    expect(component.wrapper_classes).to include('bg-canvas-50/95')
  end

  it 'uses the default lg title size' do
    component = described_class.new(eyebrow: 'Stats', title: 'Views')

    expect(component.title_classes).to include('text-lg')
  end

  it 'uses xl title size when requested' do
    component = described_class.new(eyebrow: 'Stats', title: 'Views', title_size: :xl)

    expect(component.title_classes).to include('text-2xl')
  end

  it 'uses base title size when requested' do
    component = described_class.new(eyebrow: 'Stats', title: 'Views', title_size: :base)

    expect(component.title_classes).to include('text-base')
  end

  it 'uses sm padding when requested' do
    component = described_class.new(eyebrow: 'Stats', title: 'Views', padding: :sm)

    expect(component.wrapper_classes).to include('p-4')
  end

  it 'uses md padding by default' do
    component = described_class.new(eyebrow: 'Stats', title: 'Views')

    expect(component.wrapper_classes).to include('p-5')
  end

  it 'uses lg padding when requested' do
    component = described_class.new(eyebrow: 'Stats', title: 'Views', padding: :lg)

    expect(component.wrapper_classes).to include('p-6')
  end
end
