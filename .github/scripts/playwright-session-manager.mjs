#!/usr/bin/env node

/**
 * Playwright Session Manager
 *
 * Provides isolated, task-specific browser sessions for workflow automation.
 * Each workflow execution gets its own browser context with:
 * - Full cookie/storage isolation
 * - Unique session identifier and metadata tagging
 * - Scoped screenshot and log capture
 * - Lifecycle management (create → reuse → cleanup)
 * - Context pool with concurrency limits
 *
 * Usage as a module:
 *   import { PlaywrightSessionManager } from './playwright-session-manager.mjs';
 *   const manager = new PlaywrightSessionManager({ baseUrl: 'http://localhost:3000' });
 *   await manager.launch();
 *   const session = await manager.createSession({ workflowId: 'template-audit', issueId: 'SAC-003' });
 *   await session.loginAs('demo@resume-builder.local', 'password123!');
 *   await session.navigateTo('/resumes/40');
 *   await session.screenshot('preview.png');
 *   await session.close();
 *   await manager.shutdown();
 *
 * Usage as CLI:
 *   node playwright-session-manager.mjs --action=create --workflow-id=template-audit --issue-id=SAC-003
 *   node playwright-session-manager.mjs --action=list
 *   node playwright-session-manager.mjs --action=close --session-id=<id>
 *   node playwright-session-manager.mjs --action=close-all
 */

import { chromium } from "playwright";
import fs from "fs";
import path from "path";
import crypto from "crypto";

// ── Session class ───────────────────────────────────────────────────

export class PlaywrightSession {
  /**
   * @param {object} opts
   * @param {import('playwright').BrowserContext} opts.context
   * @param {import('playwright').Page} opts.page
   * @param {string} opts.sessionId
   * @param {object} opts.metadata
   * @param {string} opts.artifactsDir
   * @param {string} opts.baseUrl
   * @param {PlaywrightSessionManager} opts.manager
   */
  constructor({ context, page, sessionId, metadata, artifactsDir, baseUrl, manager }) {
    this.context = context;
    this.page = page;
    this.sessionId = sessionId;
    this.metadata = metadata;
    this.artifactsDir = artifactsDir;
    this.baseUrl = baseUrl;
    this._manager = manager;
    this._consoleLog = [];
    this._networkFailures = [];
    this._closed = false;
    this._authenticated = false;
    this._authRole = null;
    this.createdAt = new Date().toISOString();

    this._attachListeners();
  }

  _attachListeners() {
    this.page.on("console", (msg) => {
      this._consoleLog.push({
        type: msg.type(),
        text: msg.text(),
        timestamp: new Date().toISOString(),
      });
    });

    this.page.on("requestfailed", (request) => {
      this._networkFailures.push({
        url: request.url(),
        failure: request.failure()?.errorText || "unknown",
        timestamp: new Date().toISOString(),
      });
    });

    this.page.on("crash", () => {
      console.error(`[session:${this.sessionId}] Page crashed`);
      this._closed = true;
    });
  }

  /** Navigate to a path (relative to baseUrl) or absolute URL */
  async navigateTo(urlOrPath, options = {}) {
    this._ensureOpen();
    const url = urlOrPath.startsWith("http") ? urlOrPath : this.baseUrl + urlOrPath;
    const response = await this.page.goto(url, {
      waitUntil: "networkidle",
      timeout: 30000,
      ...options,
    });
    return response;
  }

  /** Log in as a user within this isolated context */
  async loginAs(email, password) {
    this._ensureOpen();
    await this.page.goto(`${this.baseUrl}/session/new`, { waitUntil: "networkidle" });
    await this.page.fill('input[name="email_address"]', email);
    await this.page.fill('input[name="password"]', password);
    await this.page.click('input[type="submit"], button[type="submit"]');
    await this.page.waitForURL("**/resumes**", { timeout: 10000 }).catch(() => {});
    await this.page.waitForTimeout(500);
    this._authenticated = true;
    this._authRole = email;
    return this;
  }

  /** Resize the viewport within this context */
  async resize(width, height) {
    this._ensureOpen();
    await this.page.setViewportSize({ width, height });
    return this;
  }

  /** Take a screenshot scoped to this session's artifacts directory */
  async screenshot(filename, options = {}) {
    this._ensureOpen();
    const screenshotPath = path.join(this.artifactsDir, filename);
    fs.mkdirSync(path.dirname(screenshotPath), { recursive: true });
    await this.page.screenshot({
      path: screenshotPath,
      fullPage: true,
      ...options,
    });
    return screenshotPath;
  }

  /** Capture accessibility snapshot */
  async accessibilitySnapshot() {
    this._ensureOpen();
    try {
      return await this.page.accessibility.snapshot();
    } catch {
      return null;
    }
  }

  /** Evaluate JavaScript in the page */
  async evaluate(fn) {
    this._ensureOpen();
    return this.page.evaluate(fn);
  }

  /** Check for horizontal overflow */
  async checkOverflow() {
    return this.evaluate(() => {
      return document.documentElement.scrollWidth > document.documentElement.clientWidth;
    });
  }

  /** Check for translation missing leakage */
  async checkTranslationMissing() {
    const text = await this.evaluate(() => document.body?.innerText || "");
    return text.includes("Translation missing") || text.includes("translation missing");
  }

  /** Check for broken images */
  async checkBrokenImages() {
    return this.evaluate(() => {
      return Array.from(document.querySelectorAll("img"))
        .filter((img) => !img.complete || img.naturalWidth === 0)
        .map((img) => img.src);
    });
  }

  /** Get all console errors collected during this session */
  get consoleErrors() {
    return this._consoleLog.filter((e) => e.type === "error");
  }

  /** Get all console messages collected during this session */
  get consoleMessages() {
    return this._consoleLog;
  }

  /** Get all network failures collected during this session */
  get networkFailures() {
    return this._networkFailures;
  }

  /** Run a standard page health check (overflow, translations, images, console errors) */
  async healthCheck() {
    const overflow = await this.checkOverflow();
    const translationMissing = await this.checkTranslationMissing();
    const brokenImages = await this.checkBrokenImages();
    const errors = this.consoleErrors;
    const failures = this.networkFailures;

    const issues = [];
    if (overflow) issues.push("Horizontal overflow detected");
    if (translationMissing) issues.push("Translation missing leakage");
    if (brokenImages.length > 0) issues.push(`${brokenImages.length} broken image(s)`);
    if (errors.length > 0) issues.push(`${errors.length} console error(s)`);
    if (failures.length > 0) issues.push(`${failures.length} network failure(s)`);

    return {
      passed: issues.length === 0,
      issues,
      overflow,
      translationMissing,
      brokenImages,
      consoleErrors: errors,
      networkFailures: failures,
    };
  }

  /** Save session logs and metadata to the artifacts directory */
  async saveSessionReport() {
    const reportDir = this.artifactsDir;
    fs.mkdirSync(reportDir, { recursive: true });

    const report = {
      sessionId: this.sessionId,
      metadata: this.metadata,
      createdAt: this.createdAt,
      closedAt: this._closed ? new Date().toISOString() : null,
      authenticated: this._authenticated,
      authRole: this._authRole,
      consoleErrorCount: this.consoleErrors.length,
      networkFailureCount: this._networkFailures.length,
      currentUrl: this._closed ? null : this.page.url(),
    };

    fs.writeFileSync(
      path.join(reportDir, "session-report.json"),
      JSON.stringify(report, null, 2)
    );

    if (this._consoleLog.length > 0) {
      fs.writeFileSync(
        path.join(reportDir, "console.log"),
        this._consoleLog.map((m) => `[${m.timestamp}] [${m.type}] ${m.text}`).join("\n")
      );
    }

    if (this._networkFailures.length > 0) {
      fs.writeFileSync(
        path.join(reportDir, "network-failures.json"),
        JSON.stringify(this._networkFailures, null, 2)
      );
    }

    return report;
  }

  /** Close this session's page and context, releasing resources */
  async close() {
    if (this._closed) return;
    this._closed = true;

    try {
      await this.saveSessionReport();
    } catch (err) {
      console.error(`[session:${this.sessionId}] Failed to save report: ${err.message}`);
    }

    try {
      await this.page.close();
    } catch {
      // Page may already be closed
    }

    try {
      await this.context.close();
    } catch {
      // Context may already be closed
    }

    this._manager._removeSession(this.sessionId);
  }

  /** Check if the session is still usable */
  get isOpen() {
    return !this._closed;
  }

  _ensureOpen() {
    if (this._closed) {
      throw new Error(`Session ${this.sessionId} is closed`);
    }
  }
}

// ── Session Manager ─────────────────────────────────────────────────

export class PlaywrightSessionManager {
  /**
   * @param {object} opts
   * @param {string} [opts.baseUrl='http://localhost:3000']
   * @param {number} [opts.maxConcurrentSessions=8]
   * @param {string} [opts.artifactsBaseDir='tmp/playwright-sessions']
   * @param {boolean} [opts.headless=true]
   */
  constructor(opts = {}) {
    this.baseUrl = opts.baseUrl || "http://localhost:3000";
    this.maxConcurrentSessions = opts.maxConcurrentSessions || 8;
    this.artifactsBaseDir = opts.artifactsBaseDir || "tmp/playwright-sessions";
    this.headless = opts.headless !== false;
    this._browser = null;
    this._sessions = new Map();
    this._queue = [];
    this._launched = false;
  }

  /** Launch the browser. Must be called before creating sessions. */
  async launch() {
    if (this._launched) return;
    this._browser = await chromium.launch({ headless: this.headless });
    this._launched = true;
    return this;
  }

  /**
   * Create an isolated browser session for a workflow task.
   *
   * @param {object} opts
   * @param {string} opts.workflowId - Workflow identifier (e.g. 'template-audit')
   * @param {string} [opts.issueId] - Issue or task identifier (e.g. 'SAC-003')
   * @param {number} [opts.viewportWidth=1280]
   * @param {number} [opts.viewportHeight=800]
   * @param {object} [opts.extraMetadata] - Additional metadata to tag the session
   * @returns {Promise<PlaywrightSession>}
   */
  async createSession(opts = {}) {
    if (!this._launched) {
      throw new Error("Manager not launched. Call launch() first.");
    }

    // Enforce concurrency limit with queuing
    while (this._sessions.size >= this.maxConcurrentSessions) {
      console.log(
        `[manager] Concurrency limit reached (${this.maxConcurrentSessions}). ` +
        `Waiting for a session to close...`
      );
      await this._waitForSlot();
    }

    const sessionId = this._generateSessionId(opts.workflowId, opts.issueId);
    const viewportWidth = opts.viewportWidth || 1280;
    const viewportHeight = opts.viewportHeight || 800;

    const metadata = {
      workflowId: opts.workflowId || "unknown",
      issueId: opts.issueId || null,
      viewportWidth,
      viewportHeight,
      ...opts.extraMetadata,
    };

    const artifactsDir = path.join(
      this.artifactsBaseDir,
      metadata.workflowId,
      sessionId
    );
    fs.mkdirSync(artifactsDir, { recursive: true });

    const context = await this._browser.newContext({
      viewport: { width: viewportWidth, height: viewportHeight },
      // Each context gets its own cookies, localStorage, sessionStorage
      ignoreHTTPSErrors: true,
    });

    const page = await context.newPage();

    const session = new PlaywrightSession({
      context,
      page,
      sessionId,
      metadata,
      artifactsDir,
      baseUrl: this.baseUrl,
      manager: this,
    });

    this._sessions.set(sessionId, session);
    console.log(
      `[manager] Created session ${sessionId} ` +
      `(workflow: ${metadata.workflowId}, issue: ${metadata.issueId || "none"}, ` +
      `viewport: ${viewportWidth}x${viewportHeight}, ` +
      `active: ${this._sessions.size}/${this.maxConcurrentSessions})`
    );

    return session;
  }

  /**
   * Get an existing session by ID.
   * @param {string} sessionId
   * @returns {PlaywrightSession|undefined}
   */
  getSession(sessionId) {
    return this._sessions.get(sessionId);
  }

  /**
   * Get all active sessions, optionally filtered by workflow.
   * @param {string} [workflowId]
   * @returns {PlaywrightSession[]}
   */
  listSessions(workflowId) {
    const sessions = Array.from(this._sessions.values());
    if (workflowId) {
      return sessions.filter((s) => s.metadata.workflowId === workflowId);
    }
    return sessions;
  }

  /**
   * Close a specific session by ID.
   * @param {string} sessionId
   */
  async closeSession(sessionId) {
    const session = this._sessions.get(sessionId);
    if (session) {
      await session.close();
    }
  }

  /**
   * Close all sessions for a specific workflow.
   * @param {string} workflowId
   */
  async closeWorkflowSessions(workflowId) {
    const sessions = this.listSessions(workflowId);
    for (const session of sessions) {
      await session.close();
    }
  }

  /** Close all sessions and shut down the browser. */
  async shutdown() {
    const sessions = Array.from(this._sessions.values());
    for (const session of sessions) {
      await session.close();
    }

    if (this._browser) {
      await this._browser.close();
      this._browser = null;
    }

    this._launched = false;

    // Resolve any queued waiters
    for (const resolve of this._queue) {
      resolve();
    }
    this._queue = [];

    console.log("[manager] Shutdown complete");
  }

  /** Generate a session status summary */
  getStatus() {
    const sessions = Array.from(this._sessions.values()).map((s) => ({
      sessionId: s.sessionId,
      workflowId: s.metadata.workflowId,
      issueId: s.metadata.issueId,
      authenticated: s._authenticated,
      authRole: s._authRole,
      createdAt: s.createdAt,
      isOpen: s.isOpen,
      consoleErrors: s.consoleErrors.length,
      networkFailures: s.networkFailures.length,
    }));

    return {
      launched: this._launched,
      activeSessionCount: this._sessions.size,
      maxConcurrentSessions: this.maxConcurrentSessions,
      queuedRequests: this._queue.length,
      sessions,
    };
  }

  // ── Internal methods ──────────────────────────────────────────────

  _generateSessionId(workflowId, issueId) {
    const prefix = [workflowId, issueId].filter(Boolean).join("-");
    const suffix = crypto.randomBytes(4).toString("hex");
    const timestamp = new Date().toISOString().replace(/[:.]/g, "-").slice(0, 19);
    return `${prefix}-${timestamp}-${suffix}`;
  }

  _removeSession(sessionId) {
    this._sessions.delete(sessionId);
    // Notify one queued waiter that a slot is available
    if (this._queue.length > 0) {
      const resolve = this._queue.shift();
      resolve();
    }
  }

  _waitForSlot() {
    return new Promise((resolve) => {
      this._queue.push(resolve);
    });
  }
}

// ── CLI entry point ─────────────────────────────────────────────────

function parseCliArgs() {
  const args = {};
  for (const arg of process.argv.slice(2)) {
    const match = arg.match(/^--([^=]+)(?:=(.*))?$/);
    if (match) args[match[1]] = match[2] ?? "true";
  }
  return args;
}

async function cli() {
  const args = parseCliArgs();
  const action = args.action || "help";

  const manager = new PlaywrightSessionManager({
    baseUrl: args["base-url"] || process.env.PLAYWRIGHT_BASE_URL || "http://localhost:3000",
    maxConcurrentSessions: parseInt(args["max-sessions"] || "8", 10),
    artifactsBaseDir: args["artifacts-dir"] || "tmp/playwright-sessions",
    headless: args.headless !== "false",
  });

  switch (action) {
    case "create": {
      await manager.launch();
      const session = await manager.createSession({
        workflowId: args["workflow-id"] || "cli",
        issueId: args["issue-id"],
        viewportWidth: parseInt(args.width || "1280", 10),
        viewportHeight: parseInt(args.height || "800", 10),
      });

      // Optionally log in
      if (args.login) {
        const [email, password] = args.login.split(":");
        await session.loginAs(email, password);
      }

      // Optionally navigate
      if (args.url) {
        await session.navigateTo(args.url);
        const health = await session.healthCheck();
        await session.screenshot("initial.png");
        console.log(JSON.stringify({
          sessionId: session.sessionId,
          url: args.url,
          health,
          screenshotPath: path.join(session.artifactsDir, "initial.png"),
        }, null, 2));
      } else {
        console.log(JSON.stringify({
          sessionId: session.sessionId,
          artifactsDir: session.artifactsDir,
        }, null, 2));
      }

      await session.close();
      await manager.shutdown();
      break;
    }

    case "audit": {
      await manager.launch();
      const urls = (args.pages || "").split(",").filter(Boolean);
      if (urls.length === 0) {
        console.error("No pages specified. Use --pages=/path1,/path2");
        process.exitCode = 1;
        await manager.shutdown();
        return;
      }

      const session = await manager.createSession({
        workflowId: args["workflow-id"] || "audit",
        issueId: args["issue-id"],
        viewportWidth: parseInt(args.width || "1280", 10),
        viewportHeight: parseInt(args.height || "800", 10),
      });

      if (args.login) {
        const [email, password] = args.login.split(":");
        await session.loginAs(email, password);
      }

      const results = [];
      for (const url of urls) {
        await session.navigateTo(url);
        await session.page.waitForTimeout(1000);
        const health = await session.healthCheck();
        const slug = url.replace(/^\//, "").replace(/[\/\?=&]/g, "_") || "root";
        await session.screenshot(`${slug}.png`);
        results.push({ url, ...health });
      }

      console.log(JSON.stringify({
        sessionId: session.sessionId,
        workflowId: session.metadata.workflowId,
        results,
        artifactsDir: session.artifactsDir,
      }, null, 2));

      await session.close();
      await manager.shutdown();
      break;
    }

    case "help":
    default:
      console.log(`
Playwright Session Manager CLI

Actions:
  --action=create    Create an isolated browser session
    --workflow-id=<id>    Workflow identifier (required)
    --issue-id=<id>       Issue/task identifier
    --width=<px>          Viewport width (default: 1280)
    --height=<px>         Viewport height (default: 800)
    --login=<email:pass>  Log in as user
    --url=<path>          Navigate to URL and run health check

  --action=audit     Audit multiple pages in one session
    --workflow-id=<id>    Workflow identifier
    --issue-id=<id>       Issue/task identifier
    --pages=<p1,p2,...>   Comma-separated page paths
    --login=<email:pass>  Log in as user
    --width=<px>          Viewport width
    --height=<px>         Viewport height

Global options:
  --base-url=<url>        Base URL (default: http://localhost:3000)
  --max-sessions=<n>      Max concurrent sessions (default: 8)
  --artifacts-dir=<dir>   Artifacts directory (default: tmp/playwright-sessions)
  --headless=<bool>       Run headless (default: true)
`);
      break;
  }
}

// Run CLI if invoked directly
const isMain =
  process.argv[1] &&
  (process.argv[1].endsWith("playwright-session-manager.mjs") ||
   process.argv[1].endsWith("playwright-session"));

if (isMain) {
  cli().catch((err) => {
    console.error("Session manager failed:", err);
    process.exitCode = 1;
  });
}
