#!/usr/bin/env ruby

require "date"
require "fileutils"
require "json"
require "open3"
require "set"
require "time"
require "yaml"

SOURCE_REGISTRY_PATH = "docs/github_ops/registry.yml"
DEFAULT_OUTPUT_PATH = "tmp/registry-drift/report.json"
SUMMARY_STATES = %w[open closed].freeze


def load_yaml(path)
  YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
end

def repository_name(ops_registry)
  env_repo = ENV["GH_REPO"] || ENV["GITHUB_REPOSITORY"]
  return env_repo if env_repo && env_repo.include?("/")

  configured_repo = ops_registry.dig("github", "repo")
  return configured_repo if configured_repo && configured_repo.include?("/")

  output, status = Open3.capture2e("gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner")
  raise "Unable to determine GitHub repository: #{output.strip}" unless status.success?

  repo = output.strip
  raise "Unable to determine GitHub repository" if repo.empty?

  repo
end

def gh_json(*args)
  output, status = Open3.capture2e("gh", *args)
  raise "gh #{args.join(' ')} failed: #{output.strip}" unless status.success?

  JSON.parse(output)
end

def fetch_repo_issues(repo)
  gh_json(
    "issue",
    "list",
    "--repo",
    repo,
    "--state",
    "all",
    "--limit",
    "500",
    "--json",
    "number,state,title,url,labels"
  )
end

def label_names(issue)
  Array(issue["labels"]).map { |label| label["name"] }
end

def collect_issue_refs(node, refs = Set.new)
  case node
  when Hash
    node.each do |key, value|
      case key
      when "github_issue_number", "github_issue"
        refs << value.to_i if value
      when "github_issue_numbers"
        value.each_value { |number| refs << number.to_i if number } if value.is_a?(Hash)
      else
        collect_issue_refs(value, refs)
      end
    end
  when Array
    node.each { |item| collect_issue_refs(item, refs) }
  end

  refs
end

def registry_issue_refs(path)
  return { "registry_path" => path, "file_missing" => false, "linked_issue_numbers" => [] } if path.nil? || path.empty?
  return { "registry_path" => path, "file_missing" => true, "linked_issue_numbers" => [] } unless File.file?(path)

  registry = load_yaml(path)
  {
    "registry_path" => path,
    "file_missing" => false,
    "linked_issue_numbers" => collect_issue_refs(registry).to_a.sort,
  }
end

def issue_counts(issues)
  counts = Hash.new(0)
  issues.each do |issue|
    counts[issue.fetch("state").downcase] += 1
  end

  SUMMARY_STATES.each { |state| counts[state] ||= 0 }
  counts
end

def count_mismatches(summary_counts, live_counts)
  SUMMARY_STATES.each_with_object({}) do |state, mismatches|
    summary_value = summary_counts.fetch(state, 0).to_i
    live_value = live_counts.fetch(state, 0).to_i
    mismatches[state] = { "summary" => summary_value, "live" => live_value } unless summary_value == live_value
  end
end

def normalized_counts(counts)
  SUMMARY_STATES.each_with_object({}) do |state, normalized|
    normalized[state] = counts.fetch(state, counts.fetch(state.to_sym, 0)).to_i
  end
end

def drift_types_for(missing_from_summary:, stale_in_summary:, count_mismatches:, missing_on_github:, mislabeled_registry_issues:, registry_file_missing:)
  drift_types = []
  drift_types << "missing_summary_issue_refs" if missing_from_summary.any?
  drift_types << "stale_summary_issue_refs" if stale_in_summary.any?
  drift_types << "summary_count_mismatch" if count_mismatches.any?
  drift_types << "registry_links_missing_on_github" if missing_on_github.any?
  drift_types << "registry_links_wrong_workflow_label" if mislabeled_registry_issues.any?
  drift_types << "registry_file_missing" if registry_file_missing
  drift_types
end

def write_outputs(report_path, report)
  return unless ENV["GITHUB_OUTPUT"]

  lines = [
    "has_drift=#{report.fetch('drifted_workflows').any?}",
    "drift_count=#{report.fetch('drifted_workflows').length}",
    "report_path=#{report_path}",
  ]

  File.open(ENV["GITHUB_OUTPUT"], "a") { |file| file.puts(lines.join("\n")) }
end

def write_step_summary(report)
  return unless ENV["GITHUB_STEP_SUMMARY"]

  lines = [
    "# GitHub Ops Registry Drift Report",
    "",
    "Generated at: #{report.fetch('generated_at')}",
    "",
    "| Workflow | Drift types | Summary open/closed | Live open/closed |",
    "| --- | --- | --- | --- |",
  ]

  report.fetch("drifted_workflows").each do |workflow|
    summary_counts = normalized_counts(workflow.fetch("summary_issue_count"))
    live_counts = normalized_counts(workflow.fetch("live_issue_count"))
    lines << "| #{workflow.fetch('workflow')} | #{workflow.fetch('drift_types').join(', ')} | #{summary_counts.fetch('open')}/#{summary_counts.fetch('closed')} | #{live_counts.fetch('open')}/#{live_counts.fetch('closed')} |"
  end

  if report.fetch("drifted_workflows").empty?
    lines << "| none | healthy | 0/0 | 0/0 |"
  end

  report.fetch("drifted_workflows").each do |workflow|
    lines << ""
    lines << "## #{workflow.fetch('workflow')}"
    lines << ""

    if workflow.fetch("missing_from_summary").any?
      lines << "- Missing from summary: #{workflow.fetch('missing_from_summary').join(', ')}"
    end

    if workflow.fetch("stale_in_summary").any?
      lines << "- Stale in summary: #{workflow.fetch('stale_in_summary').join(', ')}"
    end

    if workflow.fetch("missing_on_github").any?
      lines << "- Registry links missing on GitHub: #{workflow.fetch('missing_on_github').join(', ')}"
    end

    if workflow.fetch("mislabeled_registry_issues").any?
      numbers = workflow.fetch("mislabeled_registry_issues").map { |entry| entry.fetch("number") }
      lines << "- Registry links without expected workflow label: #{numbers.join(', ')}"
    end

    if workflow.fetch("registry_file_missing")
      lines << "- Registry file missing: #{workflow.fetch('registry_path')}"
    end
  end

  File.open(ENV["GITHUB_STEP_SUMMARY"], "a") { |file| file.puts(lines.join("\n")) }
end

ops_registry = load_yaml(SOURCE_REGISTRY_PATH)
repo = repository_name(ops_registry)
issues = fetch_repo_issues(repo)
issue_index = issues.each_with_object({}) { |issue, memo| memo[issue.fetch("number").to_i] = issue }
workflow_registries = Array(ops_registry["workflow_registries"])

drifted_workflows = workflow_registries.filter_map do |entry|
  workflow = entry.fetch("workflow")
  workflow_label = "workflow:#{workflow}"
  live_issues = issues.select { |issue| label_names(issue).include?(workflow_label) }
  live_issue_numbers = live_issues.map { |issue| issue.fetch("number").to_i }.sort
  live_issue_count = normalized_counts(issue_counts(live_issues))
  summary_issue_numbers = Array(entry["github_issues"]).map(&:to_i).uniq.sort
  summary_issue_count = normalized_counts({
    "open" => entry.fetch("issue_count", {}).fetch("open", 0).to_i,
    "closed" => entry.fetch("issue_count", {}).fetch("closed", 0).to_i,
  })
  registry_state = registry_issue_refs(entry["registry_path"])
  missing_from_summary = live_issue_numbers - summary_issue_numbers
  stale_in_summary = summary_issue_numbers - live_issue_numbers
  missing_on_github = registry_state.fetch("linked_issue_numbers").reject { |number| issue_index.key?(number) }
  mislabeled_registry_issues = registry_state.fetch("linked_issue_numbers").filter_map do |number|
    issue = issue_index[number]
    next if issue.nil? || label_names(issue).include?(workflow_label)

    {
      "number" => number,
      "title" => issue.fetch("title"),
      "labels" => label_names(issue),
    }
  end
  mismatches = count_mismatches(summary_issue_count, live_issue_count)
  drift_types = drift_types_for(
    missing_from_summary: missing_from_summary,
    stale_in_summary: stale_in_summary,
    count_mismatches: mismatches,
    missing_on_github: missing_on_github,
    mislabeled_registry_issues: mislabeled_registry_issues,
    registry_file_missing: registry_state.fetch("file_missing")
  )
  next if drift_types.empty?

  {
    "workflow" => workflow,
    "registry_path" => registry_state.fetch("registry_path"),
    "drift_types" => drift_types,
    "summary_issue_numbers" => summary_issue_numbers,
    "live_issue_numbers" => live_issue_numbers,
    "registry_issue_numbers" => registry_state.fetch("linked_issue_numbers"),
    "summary_issue_count" => summary_issue_count,
    "live_issue_count" => live_issue_count,
    "missing_from_summary" => missing_from_summary,
    "stale_in_summary" => stale_in_summary,
    "missing_on_github" => missing_on_github,
    "mislabeled_registry_issues" => mislabeled_registry_issues,
    "registry_file_missing" => registry_state.fetch("file_missing"),
    "count_mismatches" => mismatches,
  }
end

healthy_workflows = workflow_registries.filter_map do |entry|
  workflow = entry.fetch("workflow")
  next if drifted_workflows.any? { |candidate| candidate.fetch("workflow") == workflow }

  {
    "workflow" => workflow,
    "registry_path" => entry["registry_path"],
  }
end

report = {
  "generated_at" => Time.now.utc.iso8601,
  "repository" => repo,
  "source_registry" => SOURCE_REGISTRY_PATH,
  "checked_workflows_count" => workflow_registries.length,
  "drifted_workflows" => drifted_workflows,
  "healthy_workflows" => healthy_workflows,
}

output_path = ENV["REGISTRY_DRIFT_OUTPUT"] || DEFAULT_OUTPUT_PATH
FileUtils.mkdir_p(File.dirname(output_path))
File.write(output_path, JSON.pretty_generate(report))
write_outputs(output_path, report)
write_step_summary(report)

puts "Registry drift report written to #{output_path}"
puts "Drifted workflows: #{report.fetch('drifted_workflows').length}"
report.fetch("drifted_workflows").each do |workflow|
  puts "- #{workflow.fetch('workflow')}: #{workflow.fetch('drift_types').join(', ')}"
end
