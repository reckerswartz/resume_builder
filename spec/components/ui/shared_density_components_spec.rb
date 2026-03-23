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

    it 'normalizes badges, actions, and metrics while using the default hero layout branches' do
      component = described_class.new(
        eyebrow: 'Admin',
        title: 'Dashboard',
        description: 'Track rollout status',
        avatar_text: 'RB',
        badges: [{ 'label' => 'Live' }],
        actions: [{ 'label' => 'Open', 'path' => '/admin' }],
        metrics: [
          { 'label' => 'Templates', 'value' => '12' },
          { 'label' => 'Visible', 'value' => '9' },
          { 'label' => 'Drafts', 'value' => '3' },
          { 'label' => 'Checks', 'value' => '7' }
        ]
      )

      expect(component.badges).to eq([{ label: 'Live' }])
      expect(component.actions).to eq([{ label: 'Open', path: '/admin' }])
      expect(component.metrics).to eq(
        [
          { label: 'Templates', value: '12' },
          { label: 'Visible', value: '9' },
          { label: 'Drafts', value: '3' },
          { label: 'Checks', value: '7' }
        ]
      )
      expect(component.description_classes).to include('sm:text-base')
      expect(component.badges_classes).to include('mt-5')
      expect(component.actions_classes).to include('max-w-sm')
      expect(component.avatar_classes).to include('h-16')
      expect(component.metrics_grid_classes).to include('xl:grid-cols-4')
      expect(component.metrics_wrapper_classes).to include('pt-6')
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

    it 'keeps default spacing and normalizes badges and actions for standard page headers' do
      component = described_class.new(
        eyebrow: 'Admin',
        title: 'Templates',
        description: 'Manage gallery availability',
        badges: [{ 'label' => 'Active' }],
        actions: [{ 'label' => 'Edit', 'path' => '/admin/templates/1/edit' }]
      )

      expect(component).not_to be_compact
      expect(component.badges).to eq([{ label: 'Active' }])
      expect(component.actions).to eq([{ label: 'Edit', path: '/admin/templates/1/edit' }])
      expect(component.wrapper_classes).to include('px-6')
      expect(component.divider_classes).to include('inset-x-6')
      expect(component.layout_classes).to include('gap-4')
      expect(component.eyebrow_classes).to include('text-[0.72rem]')
      expect(component.title_classes).to include('text-3xl')
      expect(component.description_classes).to include('mt-3')
      expect(component.badges_classes).to include('mt-4')
      expect(component.actions_classes).to eq('flex flex-wrap gap-2')
      expect(component.default_action_size).to eq(:md)
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

  describe Ui::SectionTabsComponent do
    let(:items) do
      [
        { label: 'Source', path: '/source', badge: 1, completed: true },
        { label: 'Experience', path: '/experience', badge: 2, current: true },
        { label: 'Summary', path: '/summary', badge: 3 }
      ]
    end

    it 'uses a horizontal mobile rail before switching back to the larger-screen grid' do
      component = described_class.new(items:, label: 'Builder steps')

      expect(component.grid_classes).to include('builder-step-tabs')
      expect(component.grid_classes).to include('sm:grid-cols-2')
      expect(component.grid_classes).to include('xl:grid-cols-3')
    end

    it 'keeps mobile cards compact while preserving larger-screen sizing' do
      component = described_class.new(items:, label: 'Builder steps')

      expect(component.link_classes(items.second)).to include('builder-step-tab')
      expect(component.badge_classes(items.second)).to include('builder-step-tab-badge')
      expect(component.link_classes(items.second)).to include('bg-ink-950')
      expect(component.badge_classes(items.third)).to include('bg-canvas-100/88')
    end
  end

  describe Ui::EmptyStateComponent do
    it 'uses the shared canvas and mist palette for subtle empty states' do
      component = described_class.new(title: 'Nothing here', description: 'Try another filter', tone: :subtle)

      expect(component.wrapper_classes).to include('bg-canvas-100/88')
      expect(component.wrapper_classes).to include('border-mist-200/80')
      expect(component.title_classes).to include('text-ink-950')
      expect(component.description_classes).to include('text-ink-700/80')
    end
  end
end
