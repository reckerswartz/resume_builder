require 'rails_helper'

RSpec.describe 'Shared density UI components' do
  describe Ui::HeroHeaderComponent do
    it 'exposes compact hero classes for dense surfaces' do
      component = described_class.new(eyebrow: 'Admin', title: 'Dashboard', density: :compact)

      expect(component).to be_compact
      expect(component.section_classes).to include('atelier-hero-compact')
      expect(component.inner_classes).to include('px-5')
      expect(component.title_classes).to include('text-3xl')
      expect(component.metrics_wrapper_classes).to include('mt-6')
    end

    it 'keeps the default hero sizing when density is not compact' do
      component = described_class.new(eyebrow: 'Admin', title: 'Dashboard')

      expect(component).not_to be_compact
      expect(component.section_classes).not_to include('atelier-hero-compact')
      expect(component.inner_classes).to include('px-6')
      expect(component.title_classes).to include('text-4xl')
      expect(component.metrics_wrapper_classes).to include('mt-8')
    end
  end

  describe Ui::PageHeaderComponent do
    it 'uses compact page header spacing and action sizing when requested' do
      component = described_class.new(eyebrow: 'Admin', title: 'Templates', density: :compact)

      expect(component).to be_compact
      expect(component.wrapper_classes).to include('page-header-compact')
      expect(component.title_classes).to include('text-2xl')
      expect(component.default_action_size).to eq(:sm)
    end
  end

  describe Ui::DashboardPanelComponent do
    it 'reduces panel spacing for compact density' do
      component = described_class.new(title: 'Quick links', density: :compact)

      expect(component).to be_compact
      expect(component.header_classes).to include('pb-4')
      expect(component.title_classes).to include('text-lg')
      expect(component.content_classes).to include('mt-4')
    end
  end

  describe Ui::StickyActionBarComponent do
    it 'uses compact sticky bar spacing when requested' do
      component = described_class.new(title: 'Save settings', density: :compact)

      expect(component).to be_compact
      expect(component.wrapper_classes).to include('sticky-action-bar-compact')
      expect(component.wrapper_classes).to include('bottom-3')
      expect(component.layout_classes).to include('gap-3')
    end
  end
end
