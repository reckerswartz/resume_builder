/**
 * Pattern Analyzer for Meta-Learning Workflow
 *
 * Analyzes collected GitHub data to identify recurring issues, effective solutions,
 * workflow inefficiencies, automation gaps, and cross-workflow correlations.
 *
 * Usage:
 *   node .github/scripts/pattern-analyzer.mjs --input tmp/meta_learning/collection.json \
 *     [--output tmp/meta_learning/analysis.json] [--min-confidence 2]
 *
 * Input:  Collection JSON from bin/gh-bridge/aggregate-history
 * Output: Structured analysis with categorized findings
 */

import { readFileSync, writeFileSync, mkdirSync } from "fs";
import { dirname } from "path";

// ── CLI Args ──────────────────────────────────────────────────────────
const args = process.argv.slice(2);
let inputPath = "";
let outputPath = "";
let minConfidence = 2;

for (let i = 0; i < args.length; i++) {
  switch (args[i]) {
    case "--input":
      inputPath = args[++i];
      break;
    case "--output":
      outputPath = args[++i];
      break;
    case "--min-confidence":
      minConfidence = parseInt(args[++i], 10);
      break;
    case "--help":
    case "-h":
      console.log("Usage: node pattern-analyzer.mjs --input <collection.json> [--output <analysis.json>] [--min-confidence N]");
      process.exit(0);
  }
}

if (!inputPath) {
  console.error("ERROR: --input is required");
  process.exit(1);
}

// ── Load Collection ───────────────────────────────────────────────────
const collection = JSON.parse(readFileSync(inputPath, "utf-8"));
const allIssues = [...(collection.issues?.open || []), ...(collection.issues?.closed || [])];
const closedIssues = collection.issues?.closed || [];
const mergedPRs = collection.pull_requests?.merged || [];
const commits = collection.commits || [];
const workflowRuns = collection.workflow_runs || [];
const registries = collection.local_registries || {};

const findings = [];
let findingCounter = 0;

function nextId(category) {
  findingCounter++;
  const prefix = {
    recurring_issue: "PATTERN",
    effective_solution: "SOLUTION",
    workflow_inefficiency: "EFFICIENCY",
    automation_gap: "GAP",
    cross_correlation: "CORRELATION",
  }[category] || "UNKNOWN";
  return `ML-${prefix}-${String(findingCounter).padStart(3, "0")}`;
}

function confidenceLabel(count) {
  if (count >= 5) return "high";
  if (count >= 3) return "medium";
  return "low";
}

// ── Analysis 1: Recurring Issues ──────────────────────────────────────
// Group issues by domain + type to find recurring patterns
function analyzeRecurringIssues() {
  const byDomainType = {};
  for (const issue of allIssues) {
    const key = `${issue.domain || "unknown"}:${issue.type || "unknown"}`;
    if (!byDomainType[key]) byDomainType[key] = [];
    byDomainType[key].push(issue);
  }

  for (const [key, issues] of Object.entries(byDomainType)) {
    if (issues.length < minConfidence) continue;
    const [domain, type] = key.split(":");
    findings.push({
      id: nextId("recurring_issue"),
      category: "recurring_issue",
      severity: issues.length >= 5 ? "high" : "medium",
      confidence: confidenceLabel(issues.length),
      title: `Recurring ${type} issues in ${domain} domain`,
      description: `${issues.length} issues of type "${type}" found in the "${domain}" domain.`,
      evidence: {
        count: issues.length,
        issue_numbers: issues.map((i) => i.number),
        domain,
        type,
        sample_titles: issues.slice(0, 5).map((i) => i.title),
      },
      actionability: issues.length >= 5 ? "automate" : "optimize",
    });
  }

  // Find file hotspots from commit messages that reference the same patterns
  const workflowCommitCounts = {};
  for (const commit of commits) {
    if (commit.workflow) {
      workflowCommitCounts[commit.workflow] = (workflowCommitCounts[commit.workflow] || 0) + 1;
    }
  }

  for (const [workflow, count] of Object.entries(workflowCommitCounts)) {
    if (count >= 5) {
      findings.push({
        id: nextId("recurring_issue"),
        category: "recurring_issue",
        severity: count >= 10 ? "high" : "medium",
        confidence: confidenceLabel(count),
        title: `High commit volume for ${workflow} workflow`,
        description: `${count} commits attributed to the "${workflow}" workflow, indicating high activity or repeated fixes.`,
        evidence: {
          commit_count: count,
          workflow,
          sample_messages: commits
            .filter((c) => c.workflow === workflow)
            .slice(0, 5)
            .map((c) => c.message),
        },
        actionability: "optimize",
      });
    }
  }
}

// ── Analysis 2: Effective Solutions ───────────────────────────────────
function analyzeEffectiveSolutions() {
  // Find fast resolutions (closed quickly, no reopening)
  const fastResolutions = closedIssues
    .filter((i) => i.resolution_hours != null && i.resolution_hours < 2)
    .sort((a, b) => a.resolution_hours - b.resolution_hours);

  if (fastResolutions.length >= minConfidence) {
    const byWorkflow = {};
    for (const issue of fastResolutions) {
      const wf = issue.workflow || "unknown";
      if (!byWorkflow[wf]) byWorkflow[wf] = [];
      byWorkflow[wf].push(issue);
    }

    for (const [workflow, issues] of Object.entries(byWorkflow)) {
      if (issues.length < minConfidence) continue;
      findings.push({
        id: nextId("effective_solution"),
        category: "effective_solution",
        severity: "medium",
        confidence: confidenceLabel(issues.length),
        title: `Fast resolution pattern in ${workflow} workflow`,
        description: `${issues.length} issues resolved in under 2 hours by the "${workflow}" workflow. These represent effective solution patterns worth replicating.`,
        evidence: {
          count: issues.length,
          workflow,
          avg_hours: (issues.reduce((sum, i) => sum + i.resolution_hours, 0) / issues.length).toFixed(1),
          issue_numbers: issues.map((i) => i.number),
          sample_titles: issues.slice(0, 5).map((i) => i.title),
        },
        actionability: "inform",
      });
    }
  }

  // Find small PRs that resolve issues (efficient fixes)
  const efficientPRs = mergedPRs
    .filter((pr) => pr.changed_files && pr.changed_files <= 5 && pr.additions < 100)
    .sort((a, b) => a.changed_files - b.changed_files);

  if (efficientPRs.length >= minConfidence) {
    findings.push({
      id: nextId("effective_solution"),
      category: "effective_solution",
      severity: "low",
      confidence: confidenceLabel(efficientPRs.length),
      title: "Small, focused PRs are the dominant merge pattern",
      description: `${efficientPRs.length} merged PRs touched ≤5 files with <100 additions. Small, focused changes are the effective norm.`,
      evidence: {
        count: efficientPRs.length,
        avg_files: (efficientPRs.reduce((s, p) => s + p.changed_files, 0) / efficientPRs.length).toFixed(1),
        avg_additions: Math.round(efficientPRs.reduce((s, p) => s + p.additions, 0) / efficientPRs.length),
        sample_titles: efficientPRs.slice(0, 5).map((p) => p.title),
      },
      actionability: "inform",
    });
  }
}

// ── Analysis 3: Workflow Efficiency ───────────────────────────────────
function analyzeWorkflowEfficiency() {
  // Compare issue counts vs commit counts per workflow (discovery-to-fix ratio)
  const issuesByWorkflow = {};
  for (const i of allIssues) {
    if (i.workflow) {
      issuesByWorkflow[i.workflow] = (issuesByWorkflow[i.workflow] || 0) + 1;
    }
  }

  const commitsByWorkflow = {};
  for (const c of commits) {
    if (c.workflow) {
      commitsByWorkflow[c.workflow] = (commitsByWorkflow[c.workflow] || 0) + 1;
    }
  }

  for (const [workflow, issueCount] of Object.entries(issuesByWorkflow)) {
    const commitCount = commitsByWorkflow[workflow] || 0;
    if (issueCount >= 3 && commitCount === 0) {
      findings.push({
        id: nextId("workflow_inefficiency"),
        category: "workflow_inefficiency",
        severity: "high",
        confidence: "medium",
        title: `${workflow} discovers issues but has no fix commits`,
        description: `The "${workflow}" workflow has ${issueCount} tracked issues but ${commitCount} commits. Findings are being discovered but not implemented.`,
        evidence: {
          workflow,
          issue_count: issueCount,
          commit_count: commitCount,
          ratio: "∞ (no fixes)",
        },
        actionability: "optimize",
      });
    }
  }

  // CI pipeline efficiency: failure rate and duration
  const ciRuns = workflowRuns.filter((r) => r.workflow === "ci");
  if (ciRuns.length > 0) {
    const completed = ciRuns.filter((r) => r.conclusion);
    const failures = completed.filter((r) => r.conclusion === "failure");
    const failureRate = completed.length > 0 ? ((failures.length / completed.length) * 100).toFixed(1) : 0;
    const avgDuration = completed
      .filter((r) => r.duration_minutes)
      .reduce((s, r, _, a) => s + r.duration_minutes / a.length, 0)
      .toFixed(1);

    if (parseFloat(failureRate) > 20) {
      findings.push({
        id: nextId("workflow_inefficiency"),
        category: "workflow_inefficiency",
        severity: parseFloat(failureRate) > 40 ? "critical" : "high",
        confidence: "high",
        title: `CI pipeline has ${failureRate}% failure rate`,
        description: `${failures.length} of ${completed.length} recent CI runs failed. Average duration: ${avgDuration} minutes.`,
        evidence: {
          workflow: "ci",
          total_runs: completed.length,
          failures: failures.length,
          failure_rate: `${failureRate}%`,
          avg_duration_minutes: avgDuration,
        },
        actionability: "automate",
      });
    }
  }
}

// ── Analysis 4: Automation Gaps ───────────────────────────────────────
function analyzeAutomationGaps() {
  // Check for workflows with no registry (manual-only tracking)
  const registryWorkflows = Object.keys(registries);
  const allWorkflows = [...new Set(allIssues.map((i) => i.workflow).filter(Boolean))];
  const untracked = allWorkflows.filter((w) => !registryWorkflows.includes(w));

  if (untracked.length > 0) {
    findings.push({
      id: nextId("automation_gap"),
      category: "automation_gap",
      severity: "medium",
      confidence: "high",
      title: `${untracked.length} workflows have issues but no local registry`,
      description: `These workflows create GitHub issues but lack local YAML registries for state tracking: ${untracked.join(", ")}`,
      evidence: {
        untracked_workflows: untracked,
        registered_workflows: registryWorkflows,
      },
      actionability: "automate",
    });
  }

  // Check for registries with open items but no recent activity
  for (const [workflow, reg] of Object.entries(registries)) {
    const openCount = (reg.issue_count?.open || 0) +
      (reg.open_discrepancies || 0) +
      (reg.open_page_issues || 0);
    const lastSync = reg.last_synced_at;

    if (openCount > 0 && lastSync) {
      const daysSinceSync = (Date.now() - new Date(lastSync).getTime()) / (1000 * 60 * 60 * 24);
      if (daysSinceSync > 7) {
        findings.push({
          id: nextId("automation_gap"),
          category: "automation_gap",
          severity: "medium",
          confidence: "high",
          title: `${workflow} has ${openCount} open items but stale sync (${Math.round(daysSinceSync)}d)`,
          description: `The "${workflow}" registry has open items but hasn't been synced in ${Math.round(daysSinceSync)} days. Items may be drifting.`,
          evidence: {
            workflow,
            open_count: openCount,
            last_synced: lastSync,
            days_since_sync: Math.round(daysSinceSync),
          },
          actionability: "optimize",
        });
      }
    }
  }

  // Check if any GitHub Actions workflows have no runs at all
  const workflowsWithRuns = new Set(workflowRuns.map((r) => r.workflow));
  const expectedWorkflows = ["ci", "playwright-audit", "issue-sync", "issue-queue", "auto-fix", "continuous-audit", "deploy"];
  const dormant = expectedWorkflows.filter((w) => !workflowsWithRuns.has(w));

  if (dormant.length > 0) {
    findings.push({
      id: nextId("automation_gap"),
      category: "automation_gap",
      severity: dormant.includes("ci") ? "critical" : "high",
      confidence: "high",
      title: `${dormant.length} CI/CD workflows have no recent runs`,
      description: `These GitHub Actions workflows have no recorded runs: ${dormant.join(", ")}. They may be inactive or misconfigured.`,
      evidence: {
        dormant_workflows: dormant,
        active_workflows: [...workflowsWithRuns],
      },
      actionability: "automate",
    });
  }
}

// ── Analysis 5: Cross-Workflow Correlations ───────────────────────────
function analyzeCrossCorrelations() {
  // Find domains where multiple workflows produce findings
  const domainWorkflows = {};
  for (const issue of allIssues) {
    if (issue.domain && issue.workflow) {
      if (!domainWorkflows[issue.domain]) domainWorkflows[issue.domain] = new Set();
      domainWorkflows[issue.domain].add(issue.workflow);
    }
  }

  for (const [domain, workflows] of Object.entries(domainWorkflows)) {
    if (workflows.size >= 3) {
      findings.push({
        id: nextId("cross_correlation"),
        category: "cross_correlation",
        severity: "medium",
        confidence: confidenceLabel(workflows.size),
        title: `${domain} domain receives findings from ${workflows.size} workflows`,
        description: `The "${domain}" domain has issues from multiple workflows: ${[...workflows].join(", ")}. This indicates either a complex surface area or overlapping audit scopes.`,
        evidence: {
          domain,
          workflow_count: workflows.size,
          workflows: [...workflows],
        },
        actionability: "optimize",
      });
    }
  }

  // Find correlated workflow activity from commit timestamps
  const commitDates = {};
  for (const c of commits) {
    if (!c.workflow || !c.date) continue;
    const day = c.date.substring(0, 10);
    if (!commitDates[day]) commitDates[day] = new Set();
    commitDates[day].add(c.workflow);
  }

  const busyDays = Object.entries(commitDates)
    .filter(([, workflows]) => workflows.size >= 3)
    .sort((a, b) => b[1].size - a[1].size);

  if (busyDays.length >= minConfidence) {
    findings.push({
      id: nextId("cross_correlation"),
      category: "cross_correlation",
      severity: "low",
      confidence: confidenceLabel(busyDays.length),
      title: `${busyDays.length} days had ≥3 workflows active simultaneously`,
      description: `Multiple workflows frequently operate on the same day, indicating high parallel activity. Ensure cross-workflow file coordination is active.`,
      evidence: {
        busy_day_count: busyDays.length,
        sample_days: busyDays.slice(0, 5).map(([day, workflows]) => ({
          date: day,
          workflows: [...workflows],
        })),
      },
      actionability: "inform",
    });
  }
}

// ── Run All Analyses ──────────────────────────────────────────────────
analyzeRecurringIssues();
analyzeEffectiveSolutions();
analyzeWorkflowEfficiency();
analyzeAutomationGaps();
analyzeCrossCorrelations();

// ── Build Output ──────────────────────────────────────────────────────
const analysis = {
  meta: {
    analyzed_at: new Date().toISOString(),
    source: inputPath,
    min_confidence: minConfidence,
    finding_count: findings.length,
  },
  summary: {
    by_category: findings.reduce((acc, f) => {
      acc[f.category] = (acc[f.category] || 0) + 1;
      return acc;
    }, {}),
    by_severity: findings.reduce((acc, f) => {
      acc[f.severity] = (acc[f.severity] || 0) + 1;
      return acc;
    }, {}),
    by_actionability: findings.reduce((acc, f) => {
      acc[f.actionability] = (acc[f.actionability] || 0) + 1;
      return acc;
    }, {}),
    automatable_count: findings.filter((f) => f.actionability === "automate").length,
    optimizable_count: findings.filter((f) => f.actionability === "optimize").length,
  },
  findings: findings.sort((a, b) => {
    const sevOrder = { critical: 0, high: 1, medium: 2, low: 3 };
    return (sevOrder[a.severity] || 4) - (sevOrder[b.severity] || 4);
  }),
  recommendations: [],
};

// Generate recommendations
if (analysis.summary.automatable_count > 0) {
  analysis.recommendations.push({
    priority: "high",
    action: `${analysis.summary.automatable_count} findings can be automated. Run /meta-learning generate to create automation rules.`,
  });
}

if (analysis.summary.optimizable_count > 0) {
  analysis.recommendations.push({
    priority: "medium",
    action: `${analysis.summary.optimizable_count} findings suggest workflow optimizations. Review and apply improvements.`,
  });
}

const criticalCount = analysis.summary.by_severity.critical || 0;
if (criticalCount > 0) {
  analysis.recommendations.push({
    priority: "critical",
    action: `${criticalCount} critical findings require immediate attention.`,
  });
}

// ── Output ────────────────────────────────────────────────────────────
const output = JSON.stringify(analysis, null, 2);

if (outputPath) {
  mkdirSync(dirname(outputPath), { recursive: true });
  writeFileSync(outputPath, output);
  console.log(`Analysis written to ${outputPath}`);
  console.log(`Findings: ${findings.length} (${analysis.summary.automatable_count} automatable, ${analysis.summary.optimizable_count} optimizable)`);
  if (analysis.recommendations.length > 0) {
    console.log("\nRecommendations:");
    for (const rec of analysis.recommendations) {
      console.log(`  [${rec.priority}] ${rec.action}`);
    }
  }
} else {
  console.log(output);
}
