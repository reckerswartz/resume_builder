require 'rails_helper'

RSpec.describe 'UI baseline contract' do
  UI_BASELINE_DOCS = [
    'docs/ui_guidelines.md',
    'docs/behance_product_ui_system.md',
    'docs/references/behance/ai_voice_generator_reference.md'
  ].freeze

  KEY_WORKFLOWS = [
    '.windsurf/workflows/feature-spec.md',
    '.windsurf/workflows/feature-review.md',
    '.windsurf/workflows/feature-plan.md',
    '.windsurf/workflows/tdd-red-agent.md',
    '.windsurf/workflows/implementation-agent.md',
    '.windsurf/workflows/tdd-refactoring-agent.md',
    '.windsurf/workflows/rspec-agent.md',
    '.windsurf/workflows/smart-fix.md',
    '.windsurf/workflows/code-review.md',
    '.windsurf/workflows/maintainability-audit.md',
    '.windsurf/workflows/security-audit.md',
    '.windsurf/workflows/template-audit.md',
    '.windsurf/workflows/behance-template-implementation.md',
    '.windsurf/workflows/resumebuilder-reference-rollout.md'
  ].freeze

  def read_repo_file(relative_path)
    Rails.root.join(relative_path).read
  end

  it 'keeps the root guidance aligned with the Behance UI baseline' do
    rules = read_repo_file('.windsurfrules')
    readme = read_repo_file('README.md')
    agents = read_repo_file('AGENTS.md')

    expect(rules).to include('Behance AI Voice is the persistent UI baseline')
    expect(rules).not_to include('vikinger-ui-agent')

    UI_BASELINE_DOCS.each do |doc|
      expect(rules).to include(doc)
      expect(readme).to include(doc)
      expect(agents).to include(doc)
    end
  end

  it 'keeps the guidelines audit registry aligned with the baseline sources' do
    registry = read_repo_file('docs/ui_audits/guidelines_review/registry.yml')

    UI_BASELINE_DOCS.each do |doc|
      expect(registry).to include(doc)
    end

    expect(registry).to include('docs/ui_audits/2026-03-20/behance-ai-voice-rollout/README.md')
  end

  KEY_WORKFLOWS.each do |workflow_path|
    it "#{workflow_path} requires the canonical UI baseline for UI-affecting work" do
      workflow = read_repo_file(workflow_path)

      UI_BASELINE_DOCS.each do |doc|
        expect(workflow).to include(doc)
      end
    end
  end
end
