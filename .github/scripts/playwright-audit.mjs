#!/usr/bin/env node

/**
 * Playwright UI Audit Runner
 *
 * Navigates seeded application pages, captures screenshots, checks for:
 * - Console errors
 * - Horizontal overflow
 * - Missing translations (Translation missing leakage)
 * - Broken images
 * - Accessibility snapshot
 *
 * Each auth group (public, authenticated, admin) runs in its own isolated
 * browser context via PlaywrightSessionManager for full cookie/storage
 * isolation and parallel-safe execution.
 *
 * Usage:
 *   node .github/scripts/playwright-audit.mjs \
 *     --base-url=http://localhost:3000 \
 *     --width=1280 --height=800 \
 *     --viewport-name=desktop \
 *     --output-dir=tmp/playwright-audit/desktop \
 *     --pages="/resumes,/templates"
 */

import { PlaywrightSessionManager } from "./playwright-session-manager.mjs";
import fs from "fs";
import path from "path";

// ── Argument parsing ────────────────────────────────────────────────
function parseArgs() {
  const args = {};
  for (const arg of process.argv.slice(2)) {
    const match = arg.match(/^--([^=]+)=(.*)$/);
    if (match) args[match[1]] = match[2];
  }
  return {
    baseUrl: args["base-url"] || "http://localhost:3000",
    width: parseInt(args["width"] || "1280", 10),
    height: parseInt(args["height"] || "800", 10),
    viewportName: args["viewport-name"] || "desktop",
    outputDir: args["output-dir"] || "tmp/playwright-audit",
    pages: args["pages"] ? args["pages"].split(",").filter(Boolean) : [],
  };
}

// ── Default page inventory ──────────────────────────────────────────
const PUBLIC_PAGES = [
  "/",
  "/session/new",
  "/registration/new",
  "/passwords/new",
];

const AUTH_PAGES = [
  "/resumes",
  "/resumes/new",
  "/templates",
];

const ADMIN_PAGES = [
  "/admin",
  "/admin/settings",
  "/admin/templates",
  "/admin/llm_providers",
  "/admin/llm_models",
  "/admin/job_logs",
  "/admin/error_logs",
];

// ── Helpers ─────────────────────────────────────────────────────────
function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function slugify(url) {
  return url.replace(/^\//, "").replace(/[\/\?=&]/g, "_") || "root";
}

// ── Core audit per page ─────────────────────────────────────────────
async function auditPage(session, url, config) {
  const slug = slugify(url);
  const pageDir = path.join(config.outputDir, slug);
  ensureDir(pageDir);

  const page = session.page;
  let statusCode = 0;
  let loadError = null;

  try {
    const response = await session.navigateTo(url);
    statusCode = response?.status() || 0;
  } catch (err) {
    loadError = err.message;
  }

  // Wait for any remaining renders
  await page.waitForTimeout(1000);

  // Screenshot
  await page.screenshot({
    path: path.join(pageDir, "screenshot.png"),
    fullPage: true,
  });

  // Check horizontal overflow
  const overflow = await session.checkOverflow();

  // Check for Translation missing
  const translationMissing = await session.checkTranslationMissing();

  // Check broken images
  const brokenImages = await session.checkBrokenImages();

  // Accessibility snapshot (text-based)
  const accessibilitySnapshot = await session.accessibilitySnapshot();

  // Collect session-scoped console errors and network failures
  const consoleErrors = session.consoleErrors;
  const networkFailures = session.networkFailures;

  // Build result
  const issues = [];
  if (statusCode >= 400) issues.push(`HTTP ${statusCode}`);
  if (loadError) issues.push(`Load error: ${loadError}`);
  if (overflow) issues.push("Horizontal overflow detected");
  if (translationMissing) issues.push("Translation missing leakage");
  if (brokenImages.length > 0) issues.push(`${brokenImages.length} broken image(s)`);
  if (consoleErrors.length > 0) issues.push(`${consoleErrors.length} console error(s)`);
  if (networkFailures.length > 0) issues.push(`${networkFailures.length} network failure(s)`);

  const result = {
    url,
    viewport: `${config.width}x${config.height}`,
    viewportName: config.viewportName,
    sessionId: session.sessionId,
    statusCode,
    loadError,
    overflow,
    translationMissing,
    brokenImages,
    consoleErrors,
    networkFailures,
    issues,
    status: issues.length === 0 ? "passed" : "failed",
    screenshotPath: path.join(slug, "screenshot.png"),
    timestamp: new Date().toISOString(),
  };

  // Write page report
  fs.writeFileSync(
    path.join(pageDir, "report.json"),
    JSON.stringify(result, null, 2)
  );

  // Write accessibility snapshot
  if (accessibilitySnapshot) {
    fs.writeFileSync(
      path.join(pageDir, "accessibility.json"),
      JSON.stringify(accessibilitySnapshot, null, 2)
    );
  }

  // Write console log
  const consoleMessages = session.consoleMessages;
  if (consoleMessages.length > 0) {
    fs.writeFileSync(
      path.join(pageDir, "console.log"),
      consoleMessages.map((m) => `[${m.type}] ${m.text}`).join("\n")
    );
  }

  return result;
}

// ── Main ────────────────────────────────────────────────────────────
async function main() {
  const config = parseArgs();
  ensureDir(config.outputDir);

  const userCredentials = process.env.AUDIT_CREDENTIALS || "demo@resume-builder.local:password123!";
  const adminCredentials = process.env.ADMIN_CREDENTIALS || "admin@resume-builder.local:password123!";

  // Initialize session manager with isolated contexts per auth group
  const manager = new PlaywrightSessionManager({
    baseUrl: config.baseUrl,
    artifactsBaseDir: config.outputDir,
  });
  await manager.launch();

  // Determine which pages to audit
  let pagesToAudit;
  if (config.pages.length > 0) {
    pagesToAudit = { custom: config.pages };
  } else {
    pagesToAudit = {
      public: PUBLIC_PAGES,
      auth: AUTH_PAGES,
      admin: ADMIN_PAGES,
    };
  }

  const allResults = [];

  // ── Public pages (isolated context, no auth) ────────────────────
  if (pagesToAudit.public || pagesToAudit.custom) {
    const pages = pagesToAudit.public || [];
    if (pages.length > 0) {
      const session = await manager.createSession({
        workflowId: "playwright-audit",
        issueId: `public-${config.viewportName}`,
        viewportWidth: config.width,
        viewportHeight: config.height,
      });
      for (const url of pages) {
        console.log(`[public] Auditing ${url} @ ${config.viewportName}`);
        const result = await auditPage(session, url, config);
        allResults.push(result);
        console.log(`  → ${result.status} (${result.issues.length} issues)`);
      }
      await session.close();
    }
  }

  // ── Authenticated pages (isolated context) ──────────────────────
  if (pagesToAudit.auth || pagesToAudit.custom) {
    const pages = pagesToAudit.auth || pagesToAudit.custom || [];
    if (pages.length > 0) {
      const session = await manager.createSession({
        workflowId: "playwright-audit",
        issueId: `auth-${config.viewportName}`,
        viewportWidth: config.width,
        viewportHeight: config.height,
      });
      const [email, password] = userCredentials.split(":");
      await session.loginAs(email, password);
      for (const url of pages) {
        console.log(`[auth] Auditing ${url} @ ${config.viewportName}`);
        const result = await auditPage(session, url, config);
        allResults.push(result);
        console.log(`  → ${result.status} (${result.issues.length} issues)`);
      }
      await session.close();
    }
  }

  // ── Admin pages (isolated context) ──────────────────────────────
  if (pagesToAudit.admin) {
    const session = await manager.createSession({
      workflowId: "playwright-audit",
      issueId: `admin-${config.viewportName}`,
      viewportWidth: config.width,
      viewportHeight: config.height,
    });
    const [email, password] = adminCredentials.split(":");
    await session.loginAs(email, password);
    for (const url of pagesToAudit.admin) {
      console.log(`[admin] Auditing ${url} @ ${config.viewportName}`);
      const result = await auditPage(session, url, config);
      allResults.push(result);
      console.log(`  → ${result.status} (${result.issues.length} issues)`);
    }
    await session.close();
  }

  await manager.shutdown();

  // Write consolidated results
  const summary = {
    viewportName: config.viewportName,
    viewport: `${config.width}x${config.height}`,
    timestamp: new Date().toISOString(),
    total_pages: allResults.length,
    passed: allResults.filter((r) => r.status === "passed").length,
    failed: allResults.filter((r) => r.status === "failed").length,
    pages: allResults,
  };

  fs.writeFileSync(
    path.join(config.outputDir, "results.json"),
    JSON.stringify(summary, null, 2)
  );

  console.log(`\nAudit complete: ${summary.passed} passed, ${summary.failed} failed out of ${summary.total_pages} pages`);

  if (summary.failed > 0) {
    process.exitCode = 1;
  }
}

main().catch((err) => {
  console.error("Audit runner failed:", err);
  process.exitCode = 1;
});
