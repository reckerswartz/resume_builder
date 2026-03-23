require 'rails_helper'

RSpec.describe Ui::SettingsSectionComponent, type: :component do
  it 'renders the title inside the section wrapper' do
    render_inline(described_class.new(title: 'Account'))

    expect(rendered_content).to include('Account')
    expect(rendered_content).to include('<section')
    expect(rendered_content).to include('text-xl font-semibold')
  end

  it 'renders the eyebrow when provided' do
    render_inline(described_class.new(title: 'Appearance', eyebrow: 'Settings'))

    expect(rendered_content).to include('Settings')
    expect(rendered_content).to include('uppercase tracking-[0.24em]')
  end

  it 'renders the description when provided' do
    render_inline(described_class.new(title: 'Export', description: 'Configure export options'))

    expect(rendered_content).to include('Configure export options')
    expect(rendered_content).to include('text-sm text-ink-700/70')
  end

  it 'omits eyebrow and description when not provided' do
    render_inline(described_class.new(title: 'Billing'))

    expect(rendered_content).not_to include('tracking-[0.24em]')
    expect(rendered_content).not_to include('text-sm text-ink-700/70')
  end

  it 'sets the anchor id on the section element' do
    render_inline(described_class.new(title: 'Notifications', anchor: 'notifications'))

    expect(rendered_content).to include('id="notifications"')
    expect(rendered_content).to include('scroll-mt-24')
  end

  it 'normalizes badge hashes and renders them' do
    component = described_class.new(
      title: 'Integrations',
      badges: [{ 'label' => 'Beta', 'tone' => 'info' }]
    )

    expect(component.badges).to eq([{ label: 'Beta', tone: 'info' }])

    render_inline(component)

    expect(rendered_content).to include('Beta')
  end

  it 'renders block content inside the content wrapper' do
    render_inline(described_class.new(title: 'Theme')) { 'Custom content here' }

    expect(rendered_content).to include('Custom content here')
    expect(rendered_content).to include('mt-5')
  end

  it 'omits the content wrapper when no block is given' do
    render_inline(described_class.new(title: 'Empty'))

    expect(rendered_content).not_to include('mt-5')
  end

  it 'returns mt-5 for content_classes' do
    component = described_class.new(title: 'Any')

    expect(component.content_classes).to eq('mt-5')
  end
end
