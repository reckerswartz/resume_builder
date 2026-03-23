require 'rails_helper'

RSpec.describe Ui::AppShellComponent do
  let(:admin_user) { build(:user, :admin, email_address: 'admin@example.com') }
  let(:standard_user) { build(:user, email_address: 'user@example.com') }

  describe '#authenticated?' do
    it 'casts truthy values to true' do
      component = described_class.new(current_user: standard_user, authenticated: true, controller_path: 'resumes', controller_name: 'resumes')

      expect(component).to be_authenticated
    end

    it 'casts falsy values to false' do
      component = described_class.new(current_user: nil, authenticated: false, controller_path: 'sessions', controller_name: 'sessions')

      expect(component).not_to be_authenticated
    end
  end

  describe '#admin?' do
    it 'returns true when the current user is an admin' do
      component = described_class.new(current_user: admin_user, authenticated: true, controller_path: 'admin/dashboard', controller_name: 'dashboard')

      expect(component).to be_admin
    end

    it 'returns false when the current user is a standard user' do
      component = described_class.new(current_user: standard_user, authenticated: true, controller_path: 'resumes', controller_name: 'resumes')

      expect(component).not_to be_admin
    end

    it 'returns false when there is no current user' do
      component = described_class.new(current_user: nil, authenticated: false, controller_path: 'sessions', controller_name: 'sessions')

      expect(component).not_to be_admin
    end
  end

  describe '#wrapper_classes' do
    it 'uses the authenticated layout with sidebar gap when signed in' do
      component = described_class.new(current_user: standard_user, authenticated: true, controller_path: 'resumes', controller_name: 'resumes')

      expect(component.wrapper_classes).to include('gap-5')
      expect(component.wrapper_classes).to include('max-w-[100rem]')
    end

    it 'uses the public layout without sidebar gap when signed out' do
      component = described_class.new(current_user: nil, authenticated: false, controller_path: 'sessions', controller_name: 'sessions')

      expect(component.wrapper_classes).to include('max-w-7xl')
      expect(component.wrapper_classes).to include('flex-col')
    end
  end

  describe '#main_classes' do
    it 'constrains the main column to flex-1 for authenticated users' do
      component = described_class.new(current_user: standard_user, authenticated: true, controller_path: 'resumes', controller_name: 'resumes')

      expect(component.main_classes).to include('flex-1')
      expect(component.main_classes).to include('space-y-5')
    end

    it 'uses full width for unauthenticated users' do
      component = described_class.new(current_user: nil, authenticated: false, controller_path: 'sessions', controller_name: 'sessions')

      expect(component.main_classes).to eq('w-full')
    end
  end

  describe '#header_link_classes' do
    it 'highlights the active header link with opaque background' do
      component = described_class.new(current_user: standard_user, authenticated: true, controller_path: 'resumes', controller_name: 'resumes')

      expect(component.header_link_classes(true)).to include('bg-canvas-50')
      expect(component.header_link_classes(true)).to include('text-ink-950')
    end

    it 'applies translucent styling to inactive header links' do
      component = described_class.new(current_user: standard_user, authenticated: true, controller_path: 'resumes', controller_name: 'resumes')

      expect(component.header_link_classes(false)).to include('bg-white/4')
      expect(component.header_link_classes(false)).to include('text-white/72')
    end
  end

  describe '#sidebar_link_classes' do
    it 'highlights the active sidebar link with a dark surface' do
      component = described_class.new(current_user: standard_user, authenticated: true, controller_path: 'resumes', controller_name: 'resumes')

      expect(component.sidebar_link_classes(true)).to include('bg-ink-950')
      expect(component.sidebar_link_classes(true)).to include('text-white')
    end

    it 'applies a subtle surface to inactive sidebar links' do
      component = described_class.new(current_user: standard_user, authenticated: true, controller_path: 'resumes', controller_name: 'resumes')

      expect(component.sidebar_link_classes(false)).to include('bg-canvas-50/92')
      expect(component.sidebar_link_classes(false)).to include('text-ink-700')
    end
  end

  describe '#current_area_label' do
    it 'returns the admin hub label for admin paths' do
      component = described_class.new(current_user: admin_user, authenticated: true, controller_path: 'admin/templates', controller_name: 'templates')

      expect(component.current_area_label).to eq('Admin hub')
    end

    it 'returns the template gallery label for the user-facing templates controller' do
      component = described_class.new(current_user: standard_user, authenticated: true, controller_path: 'templates', controller_name: 'templates')

      expect(component.current_area_label).to eq('Template gallery')
    end

    it 'returns the resume workspace label for the resumes controller' do
      component = described_class.new(current_user: standard_user, authenticated: true, controller_path: 'resumes', controller_name: 'resumes')
      helpers = double('helpers', new_resume_path: '/resumes/new')

      allow(component).to receive(:helpers).and_return(helpers)
      allow(helpers).to receive(:current_page?).and_return(false)

      expect(component.current_area_label).to eq('Resume workspace')
    end
  end

  describe '#current_area_badges' do
    it 'includes admin access badge for admin users' do
      component = described_class.new(current_user: admin_user, authenticated: true, controller_path: 'admin/dashboard', controller_name: 'dashboard')

      expect(component.current_area_badges).to include('Admin access')
      expect(component.current_area_badges).to include('Reporting shell')
    end

    it 'includes signed in badge for standard users' do
      component = described_class.new(current_user: standard_user, authenticated: true, controller_path: 'resumes', controller_name: 'resumes')

      expect(component.current_area_badges).to include('Signed in')
      expect(component.current_area_badges).to include('Guided workspace')
    end
  end

  describe '#brand_supporting_text' do
    it 'returns the authenticated tagline when signed in' do
      component = described_class.new(current_user: standard_user, authenticated: true, controller_path: 'resumes', controller_name: 'resumes')

      expect(component.brand_supporting_text).to eq('Guided resumes and admin tools')
    end

    it 'returns the public tagline when signed out' do
      component = described_class.new(current_user: nil, authenticated: false, controller_path: 'sessions', controller_name: 'sessions')

      expect(component.brand_supporting_text).to eq('Build polished resumes faster')
    end
  end
end
