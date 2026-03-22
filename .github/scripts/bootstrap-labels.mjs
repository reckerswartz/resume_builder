#!/usr/bin/env node

/**
 * Bootstrap GitHub Labels
 *
 * Creates the labels required by the CI/CD pipeline.
 * Run manually or via: gh api repos/:owner/:repo/labels --method POST ...
 *
 * Usage:
 *   GITHUB_TOKEN=ghp_... node .github/scripts/bootstrap-labels.mjs
 *
 * Or use the GitHub CLI:
 *   node .github/scripts/bootstrap-labels.mjs --dry-run
 */

const LABELS = [
  // Pipeline automation
  { name: "ci-auto", color: "d93f0b", description: "Auto-created by CI pipeline" },
  { name: "ui-audit", color: "c5def5", description: "UI audit finding from Playwright" },
  { name: "auto-fix", color: "0e8a16", description: "Auto-generated fix PR" },
  { name: "in-progress", color: "fbca04", description: "Currently being processed by automation" },
  { name: "needs-review", color: "e4e669", description: "Requires human review" },
  { name: "full-ci", color: "bfd4f2", description: "PR label to trigger full CI suite including system specs" },

  // Priority
  { name: "priority:critical", color: "b60205", description: "Must fix immediately" },
  { name: "priority:high", color: "d93f0b", description: "Fix in current cycle" },
  { name: "priority:medium", color: "fbca04", description: "Fix when capacity allows" },
  { name: "priority:low", color: "0e8a16", description: "Nice to have" },

  // Category
  { name: "bug", color: "d73a4a", description: "Something is not working" },
  { name: "security", color: "b60205", description: "Security vulnerability or concern" },
  { name: "test-failure", color: "e11d48", description: "Failing test" },
  { name: "performance", color: "f9a825", description: "Performance issue" },
  { name: "architecture", color: "7057ff", description: "Architecture or design concern" },
  { name: "deploy", color: "006b75", description: "Deployment related" },

  // Scope
  { name: "scope:ui", color: "c5def5", description: "User interface" },
  { name: "scope:api", color: "bfdadc", description: "API or backend" },
  { name: "scope:ci-cd", color: "d4c5f9", description: "CI/CD pipeline" },
  { name: "scope:templates", color: "fef2c0", description: "Resume templates" },
  { name: "scope:admin", color: "f9d0c4", description: "Admin panel" },
];

async function main() {
  const dryRun = process.argv.includes("--dry-run");
  const token = process.env.GITHUB_TOKEN;
  const repo = process.env.GITHUB_REPOSITORY;

  if (!dryRun && (!token || !repo)) {
    console.error("Set GITHUB_TOKEN and GITHUB_REPOSITORY environment variables");
    console.error("Or run with --dry-run to preview labels");
    process.exit(1);
  }

  if (dryRun) {
    console.log("Labels that would be created:\n");
    for (const label of LABELS) {
      console.log(`  #${label.color} ${label.name} — ${label.description}`);
    }
    console.log(`\nTotal: ${LABELS.length} labels`);
    return;
  }

  const [owner, repoName] = repo.split("/");
  const baseUrl = `https://api.github.com/repos/${owner}/${repoName}/labels`;

  let created = 0;
  let updated = 0;
  let skipped = 0;

  for (const label of LABELS) {
    // Try to create
    const createResp = await fetch(baseUrl, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        Accept: "application/vnd.github+json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify(label),
    });

    if (createResp.ok) {
      created++;
      console.log(`  Created: ${label.name}`);
    } else if (createResp.status === 422) {
      // Already exists — update it
      const updateResp = await fetch(`${baseUrl}/${encodeURIComponent(label.name)}`, {
        method: "PATCH",
        headers: {
          Authorization: `Bearer ${token}`,
          Accept: "application/vnd.github+json",
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ color: label.color, description: label.description }),
      });
      if (updateResp.ok) {
        updated++;
        console.log(`  Updated: ${label.name}`);
      } else {
        skipped++;
        console.log(`  Skipped: ${label.name} (${updateResp.status})`);
      }
    } else {
      skipped++;
      console.log(`  Failed: ${label.name} (${createResp.status})`);
    }
  }

  console.log(`\nDone: ${created} created, ${updated} updated, ${skipped} skipped`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
