require 'rails_helper'

RSpec.describe Ui::StepHeaderComponent, type: :component do
  it 'renders the title inside a header bar' do
    render_inline(described_class.new(title: 'Contact Details'))

    expect(rendered_content).to include('Contact Details')
    expect(rendered_content).to include('text-xl font-semibold tracking-tight')
    expect(rendered_content).to include('bg-canvas-100/84')
  end

  it 'renders the description when provided' do
    render_inline(described_class.new(title: 'Experience', description: 'Add your work history'))

    expect(rendered_content).to include('Add your work history')
    expect(rendered_content).to include('text-sm text-ink-700/80')
    expect(rendered_content).to include('max-w-2xl')
  end

  it 'omits the description paragraph when not provided' do
    render_inline(described_class.new(title: 'Skills'))

    expect(rendered_content).not_to include('text-ink-700/80')
  end

  it 'renders block content in the aside slot with default classes' do
    render_inline(described_class.new(title: 'Summary')) { 'Aside content' }

    expect(rendered_content).to include('Aside content')
    expect(rendered_content).to include('w-full lg:max-w-sm')
  end

  it 'uses custom aside_classes when provided' do
    render_inline(described_class.new(title: 'Education', aside_classes: 'w-64')) { 'Actions' }

    expect(rendered_content).to include('w-64')
    expect(rendered_content).not_to include('lg:max-w-sm')
  end

  it 'omits the aside wrapper when no block is given' do
    render_inline(described_class.new(title: 'Projects'))

    expect(rendered_content).not_to include('lg:max-w-sm')
  end

  it 'returns the default aside classes when aside_classes is nil' do
    component = described_class.new(title: 'Any')

    expect(component.resolved_aside_classes).to eq('w-full lg:max-w-sm')
  end

  it 'returns the custom aside classes when provided' do
    component = described_class.new(title: 'Any', aside_classes: 'w-48 shrink-0')

    expect(component.resolved_aside_classes).to eq('w-48 shrink-0')
  end
end
