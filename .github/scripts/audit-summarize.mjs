#!/usr/bin/env node

/**
 * Audit Summarizer
 *
 * Consolidates per-viewport Playwright audit results into a single summary.
 *
 * Usage:
 *   node .github/scripts/audit-summarize.mjs \
 *     --input-dir=tmp/playwright-results/ \
 *     --output=tmp/audit-summary.json
 */

import fs from "fs";
import path from "path";

function parseArgs() {
  const args = {};
  for (const arg of process.argv.slice(2)) {
    const m = arg.match(/^--([^=]+)=(.*)$/);
    if (m) args[m[1]] = m[2];
  }
  return {
    inputDir: args["input-dir"] || "tmp/playwright-results",
    output: args["output"] || "tmp/audit-summary.json",
  };
}

function findResultFiles(dir) {
  const files = [];
  if (!fs.existsSync(dir)) return files;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...findResultFiles(full));
    } else if (entry.name === "results.json") {
      files.push(full);
    }
  }
  return files;
}

function main() {
  const config = parseArgs();
  const resultFiles = findResultFiles(config.inputDir);

  const viewports = [];
  const allPages = [];
  const failures = [];
  let totalPassed = 0;
  let totalFailed = 0;
  let totalWarnings = 0;

  for (const file of resultFiles) {
    const data = JSON.parse(fs.readFileSync(file, "utf8"));
    if (data.viewportName && !viewports.includes(data.viewportName)) {
      viewports.push(data.viewportName);
    }

    for (const page of data.pages || []) {
      allPages.push({
        url: page.url,
        viewport: page.viewportName || data.viewportName,
        status: page.status,
        issues: page.issues || [],
      });

      if (page.status === "failed") {
        totalFailed++;
        for (const issue of page.issues || []) {
          failures.push({
            page: page.url,
            viewport: page.viewportName || data.viewportName,
            reason: issue,
          });
        }
      } else {
        totalPassed++;
      }
    }
  }

  const summary = {
    timestamp: new Date().toISOString(),
    viewports,
    total_pages: allPages.length,
    passed: totalPassed,
    failed: totalFailed,
    warnings: totalWarnings,
    failures,
    pages: allPages,
  };

  const hasFailures = totalFailed > 0;

  // Write summary file
  fs.mkdirSync(path.dirname(config.output), { recursive: true });
  fs.writeFileSync(config.output, JSON.stringify(summary, null, 2));

  // Set GitHub Actions output
  if (process.env.GITHUB_OUTPUT) {
    fs.appendFileSync(
      process.env.GITHUB_OUTPUT,
      `has_failures=${hasFailures}\n`
    );
    // Truncate summary for output (GitHub has 1MB limit)
    const compactSummary = JSON.stringify({
      total_pages: summary.total_pages,
      passed: summary.passed,
      failed: summary.failed,
      viewports: summary.viewports,
      failure_count: failures.length,
    });
    fs.appendFileSync(
      process.env.GITHUB_OUTPUT,
      `summary_json=${compactSummary}\n`
    );
  }

  console.log(`Consolidated ${resultFiles.length} viewport result(s)`);
  console.log(`  Total pages: ${summary.total_pages}`);
  console.log(`  Passed: ${summary.passed}`);
  console.log(`  Failed: ${summary.failed}`);

  if (failures.length > 0) {
    console.log("\nFailures:");
    for (const f of failures) {
      console.log(`  - ${f.page} @ ${f.viewport}: ${f.reason}`);
    }
  }
}

main();
