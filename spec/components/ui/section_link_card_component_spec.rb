require 'rails_helper'

RSpec.describe Ui::SectionLinkCardComponent, type: :component do
  it 'renders a link with the label and wrapper classes' do
    render_inline(described_class.new(label: 'Experience', path: '/resumes/1/experience'))

    expect(rendered_content).to include('Experience')
    expect(rendered_content).to include('href="/resumes/1/experience"')
    expect(rendered_content).to include('rounded-[1.25rem]')
  end

  it 'renders the caption when provided' do
    render_inline(described_class.new(label: 'Skills', path: '/skills', caption: 'Add your top skills'))

    expect(rendered_content).to include('Skills')
    expect(rendered_content).to include('Add your top skills')
    expect(rendered_content).to include('text-xs')
  end

  it 'omits the caption span when caption is nil' do
    render_inline(described_class.new(label: 'Summary', path: '/summary'))

    expect(rendered_content).not_to include('text-xs text-ink-700/70')
  end

  it 'exposes consistent wrapper classes for the card link' do
    component = described_class.new(label: 'Education', path: '/education')

    expect(component.wrapper_classes).to include('rounded-[1.25rem]')
    expect(component.wrapper_classes).to include('border-canvas-200/80')
    expect(component.wrapper_classes).to include('hover:border-mist-300')
    expect(component.wrapper_classes).to include('px-4')
  end
end
