require 'rails_helper'

RSpec.describe Ui::SurfaceCardComponent, type: :component do
  it 'renders a section tag with default tone and padding' do
    render_inline(described_class.new) { 'Card body' }

    expect(rendered_content).to include('<section')
    expect(rendered_content).to include('Card body')
    expect(rendered_content).to include('atelier-panel')
    expect(rendered_content).to include('p-6')
  end

  it 'renders with a custom tag name' do
    render_inline(described_class.new(tag: :div)) { 'Div content' }

    expect(rendered_content).to include('<div')
    expect(rendered_content).to include('Div content')
    expect(rendered_content).not_to include('<section')
  end

  it 'applies extra_classes alongside surface classes' do
    render_inline(described_class.new(extra_classes: 'overflow-hidden')) { 'Content' }

    expect(rendered_content).to include('overflow-hidden')
    expect(rendered_content).to include('atelier-panel')
  end

  it 'renders with small padding' do
    render_inline(described_class.new(padding: :sm)) { 'Compact' }

    expect(rendered_content).to include('p-5')
  end

  it 'renders with large padding' do
    render_inline(described_class.new(padding: :lg)) { 'Spacious' }

    expect(rendered_content).to include('p-8')
  end

  it 'applies the brand tone' do
    render_inline(described_class.new(tone: :brand)) { 'Brand card' }

    expect(rendered_content).to include('atelier-panel-dark')
  end

  it 'applies the subtle tone' do
    render_inline(described_class.new(tone: :subtle)) { 'Subtle card' }

    expect(rendered_content).to include('atelier-panel-subtle')
  end

  it 'applies the danger tone' do
    render_inline(described_class.new(tone: :danger)) { 'Danger card' }

    expect(rendered_content).to include('border-rose-200/80')
  end

  it 'merges html_options into the rendered tag' do
    render_inline(described_class.new(html_options: { id: 'my-card', data: { controller: 'panel' } })) { 'Options' }

    expect(rendered_content).to include('id="my-card"')
    expect(rendered_content).to include('data-controller="panel"')
  end

  it 'merges html_options class with surface classes' do
    render_inline(described_class.new(html_options: { class: 'custom-class' })) { 'Merged' }

    expect(rendered_content).to include('atelier-panel')
    expect(rendered_content).to include('custom-class')
  end
end
