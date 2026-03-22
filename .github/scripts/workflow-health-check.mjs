#!/usr/bin/env node

import fs from "fs";
import path from "path";

const DEFAULT_TARGETS = [
  {
    key: "auto-fix",
    workflow_id: "auto-fix.yml",
    workflow_name: "Auto Fix & PR",
    max_age_days: 7,
  },
  {
    key: "continuous-audit",
    workflow_id: "continuous-audit.yml",
    workflow_name: "Continuous Audit Cycle",
    max_age_days: 7,
  },
];

function loadTargets() {
  if (!process.env.WORKFLOW_HEALTH_TARGETS) {
    return DEFAULT_TARGETS;
  }

  const parsed = JSON.parse(process.env.WORKFLOW_HEALTH_TARGETS);
  if (!Array.isArray(parsed) || parsed.length === 0) {
    throw new Error("WORKFLOW_HEALTH_TARGETS must be a non-empty JSON array");
  }

  return parsed.map((target) => ({
    key: target.key || target.workflow_id,
    workflow_id: target.workflow_id,
    workflow_name: target.workflow_name || target.workflow_id,
    max_age_days: Number(target.max_age_days || 7),
  }));
}

function loadRepository() {
  const repository = process.env.GITHUB_REPOSITORY;
  if (!repository || !repository.includes("/")) {
    throw new Error("GITHUB_REPOSITORY is required");
  }

  const [owner, repo] = repository.split("/");
  return { owner, repo, repository };
}

function workflowApiUrl(owner, repo, workflowId) {
  const apiBase = (process.env.GITHUB_API_URL || "https://api.github.com").replace(/\/$/, "");
  return `${apiBase}/repos/${owner}/${repo}/actions/workflows/${encodeURIComponent(workflowId)}/runs?per_page=1`;
}

async function requestJson(url) {
  const token = process.env.GITHUB_TOKEN;
  if (!token) {
    throw new Error("GITHUB_TOKEN is required");
  }

  const response = await fetch(url, {
    headers: {
      Accept: "application/vnd.github+json",
      Authorization: `Bearer ${token}`,
      "User-Agent": "resume-builder-workflow-health-check",
    },
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`GitHub API request failed (${response.status}): ${body}`);
  }

  return response.json();
}

function roundDays(value) {
  return Math.round(value * 10) / 10;
}

function buildWorkflowReport(target, run) {
  if (!run) {
    return {
      key: target.key,
      workflow_id: target.workflow_id,
      workflow_name: target.workflow_name,
      max_age_days: target.max_age_days,
      status: "dormant",
      reason: `No runs found within GitHub Actions history for ${target.workflow_name}.`,
      latest_run: null,
      latest_run_age_days: null,
    };
  }

  const latestTimestamp = run.run_started_at || run.created_at || run.updated_at;
  const latestAgeDays = roundDays((Date.now() - new Date(latestTimestamp).getTime()) / 86400000);
  const dormant = latestAgeDays > target.max_age_days;

  return {
    key: target.key,
    workflow_id: target.workflow_id,
    workflow_name: target.workflow_name,
    max_age_days: target.max_age_days,
    status: dormant ? "dormant" : "healthy",
    reason: dormant
      ? `Latest run is ${latestAgeDays} days old, which exceeds the ${target.max_age_days}-day threshold.`
      : `Latest run is ${latestAgeDays} days old and within the ${target.max_age_days}-day threshold.`,
    latest_run_age_days: latestAgeDays,
    latest_run: {
      id: run.id,
      name: run.name,
      display_title: run.display_title,
      html_url: run.html_url,
      status: run.status,
      conclusion: run.conclusion,
      created_at: run.created_at,
      run_started_at: run.run_started_at,
      updated_at: run.updated_at,
    },
  };
}

function writeOutputs(reportPath, report) {
  if (!process.env.GITHUB_OUTPUT) {
    return;
  }

  const lines = [
    `has_dormant=${report.dormant_workflows.length > 0}`,
    `dormant_count=${report.dormant_workflows.length}`,
    `report_path=${reportPath}`,
  ];

  fs.appendFileSync(process.env.GITHUB_OUTPUT, `${lines.join("\n")}\n`);
}

function writeStepSummary(report) {
  if (!process.env.GITHUB_STEP_SUMMARY) {
    return;
  }

  const lines = [
    "# Workflow Health Report",
    "",
    `Generated at: ${report.generated_at}`,
    "",
    "| Workflow | Latest run | Age (days) | Status |",
    "| --- | --- | --- | --- |",
  ];

  for (const workflow of report.monitored_workflows) {
    const latestRun = workflow.latest_run
      ? `[${workflow.latest_run.display_title || workflow.latest_run.name || workflow.latest_run.id}](${workflow.latest_run.html_url})`
      : "No runs found";
    const age = workflow.latest_run_age_days == null ? "n/a" : workflow.latest_run_age_days;
    lines.push(`| ${workflow.workflow_name} | ${latestRun} | ${age} | ${workflow.status} |`);
  }

  if (report.dormant_workflows.length > 0) {
    lines.push("", "## Dormant workflows", "");
    for (const workflow of report.dormant_workflows) {
      lines.push(`- **${workflow.workflow_name}** — ${workflow.reason}`);
    }
  }

  fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY, `${lines.join("\n")}\n`);
}

async function main() {
  const targets = loadTargets();
  const { owner, repo, repository } = loadRepository();
  const monitoredWorkflows = [];

  for (const target of targets) {
    const data = await requestJson(workflowApiUrl(owner, repo, target.workflow_id));
    monitoredWorkflows.push(buildWorkflowReport(target, data.workflow_runs?.[0]));
  }

  const dormantWorkflows = monitoredWorkflows.filter((workflow) => workflow.status === "dormant");
  const report = {
    generated_at: new Date().toISOString(),
    repository,
    monitored_workflows: monitoredWorkflows,
    dormant_workflows: dormantWorkflows,
    healthy_workflows: monitoredWorkflows.filter((workflow) => workflow.status === "healthy"),
  };

  const outputPath = process.env.WORKFLOW_HEALTH_OUTPUT || "tmp/workflow-health/report.json";
  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  fs.writeFileSync(outputPath, JSON.stringify(report, null, 2));

  writeOutputs(outputPath, report);
  writeStepSummary(report);

  console.log(`Workflow health report written to ${outputPath}`);
  console.log(`Dormant workflows: ${report.dormant_workflows.length}`);
  for (const workflow of report.monitored_workflows) {
    console.log(`- ${workflow.workflow_name}: ${workflow.status}`);
  }
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
