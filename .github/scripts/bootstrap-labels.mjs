#!/usr/bin/env node

/**
 * Bootstrap GitHub Labels — Preview Tool
 *
 * Lists the labels required by the CI/CD pipeline.
 * Actual label creation/updates are handled by the bootstrap-labels.yml
 * GitHub Actions workflow, which uses the built-in GITHUB_TOKEN automatically.
 *
 * Usage:
 *   node .github/scripts/bootstrap-labels.mjs
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

console.log("Pipeline labels (managed by .github/workflows/bootstrap-labels.yml):\n");
for (const label of LABELS) {
  console.log(`  #${label.color}  ${label.name} — ${label.description}`);
}
console.log(`\nTotal: ${LABELS.length} labels`);
console.log("\nTo create/update these labels, push this file to main or run the");
console.log("'Bootstrap Labels' workflow manually from the Actions tab.");
