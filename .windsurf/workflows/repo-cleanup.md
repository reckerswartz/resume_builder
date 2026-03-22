---
description: Audit the repository and remove unnecessary files, artifacts, and committed outputs from Git to keep it clean and lightweight.
---

# Repository Cleanup Workflow

Continuously audit the repository for unnecessary tracked files, update .gitignore, remove ephemeral artifacts, and validate nothing is broken.

## Phase 1 — Audit

1. **Scan for cleanup candidates**
   ```bash
   # Tracked files by category
   git ls-files -- docs/ | wc -l
   git ls-files | grep -E '/runs/[0-9]{4}-.*/00-overview\.md$' | wc -l
   git ls-files | grep -E '/runs/TEMPLATE\.md$' | wc -l
   git ls-files -- docs/ui_audits/2026-03-20/ | wc -l
   git ls-files | grep -E '\.png$|\.jpg$|\.jpeg$|\.pdf$' | head -30
   # Untracked artifacts on disk
   du -sh tmp/ui_audit_artifacts/ tmp/reference_captures/ tmp/reference_artifacts/ 2>/dev/null
   # Repo size
   du -sh --exclude=.git .
   ```

2. **Classify findings** into:
   - **Safe to delete** — run logs, TEMPLATE scaffolds, one-time audit snapshots, personal files
   - **Should be .gitignored** — tmp/ artifacts, future run logs, build outputs, Playwright reports
   - **Needs review** — anything that might be referenced by code or specs

## Phase 2 — .gitignore Update

3. **Update `.gitignore`** with comprehensive patterns:
   ```gitignore
   # Audit run logs (ephemeral per-execution chronicles)
   docs/*/runs/
   docs/*/*/runs/
   docs/*/*/*/runs/

   # Historical one-time audit snapshots
   docs/ui_audits/2026-03-20/

   # Playwright and audit artifacts
   /tmp/ui_audit_artifacts/
   /tmp/reference_captures/
   /tmp/reference_artifacts/

   # Generated template PDFs
   docs/templates/*.pdf

   # Build artifacts (already present, verify)
   /app/assets/builds/*
   !/app/assets/builds/.keep

   # Template audit artifacts (already present, verify)
   /docs/template_audits/artifacts/
   ```

## Phase 3 — Cleanup Execution

4. **Remove ephemeral run logs from Git tracking:**
   ```bash
   git ls-files | grep -E '/runs/[0-9]{4}-.*/00-overview\.md$' | xargs git rm --cached
   git ls-files | grep -E '/runs/TEMPLATE\.md$' | xargs git rm --cached
   ```

5. **Remove one-time audit snapshots:**
   ```bash
   git rm --cached -r docs/ui_audits/2026-03-20/
   ```

6. **Remove template scaffolds:**
   ```bash
   git rm --cached docs/maintainability_audits/areas/TEMPLATE.md
   ```

7. **Delete files from disk** (run logs are disposable):
   ```bash
   # Only delete the files that were just untracked — they serve no ongoing purpose
   find docs/ -path '*/runs/*/00-overview.md' -delete
   find docs/ -path '*/runs/TEMPLATE.md' -delete
   find docs/ -name '.keep' -path '*/runs/*' -delete
   find docs/ -type d -path '*/runs/*' -empty -delete
   rm -rf docs/ui_audits/2026-03-20/
   rm -f docs/maintainability_audits/areas/TEMPLATE.md
   rm -f docs/maintainability_audits/runs/TEMPLATE.md
   ```

## Phase 4 — Dependency Check

8. **Verify no unused gems or packages:**
   ```bash
   # Check Gemfile for gems that are never required/used
   bundle exec ruby -e 'puts Bundler.definition.specs.map(&:name).sort'
   # Check package.json — should only have Stimulus, Turbo, Tailwind, Webpack, Playwright
   cat package.json | ruby -rjson -e 'j=JSON.parse(STDIN.read); puts (j["dependencies"]||{}).keys + (j["devDependencies"]||{}).keys'
   ```

## Phase 5 — Validation

9. **Run the full spec suite:**
   ```bash
   bundle exec rspec
   ```

10. **Verify syntax and YAML:**
    ```bash
    ruby -c db/seeds.rb
    ruby -ryaml -e 'YAML.load_file("docs/maintainability_audits/registry.yml")'
    ruby -ryaml -e 'YAML.load_file("docs/template_audits/registry.yml")'
    ruby -ryaml -e 'YAML.load_file("docs/ui_audits/guidelines_review/registry.yml")'
    ruby -ryaml -e 'YAML.load_file("docs/ui_audits/responsive_review/registry.yml")'
    ruby -ryaml -e 'YAML.load_file("docs/ui_audits/usability_review/registry.yml")'
    ```

11. **Verify build still works:**
    ```bash
    yarn build:dev
    ```

## Phase 6 — Commit

12. **Create a cleanup branch, commit, and push:**
    ```bash
    git checkout -b chore/repo-cleanup
    git add .gitignore
    git add -u  # stages all removals
    git commit -m "chore: remove ephemeral audit run logs and update .gitignore

    - Remove 90+ run log files (ephemeral per-execution chronicles)
    - Remove 51 one-time initial audit snapshot files
    - Remove scaffolding TEMPLATE files
    - Update .gitignore to prevent re-committing run logs, audit artifacts, and tmp/ outputs
    - No code, dependency, or functionality changes"
    git push origin chore/repo-cleanup
    ```

## Phase 7 — Continuous Enforcement

13. **Add CI check** to `.github/workflows/ci.yml`:
    ```yaml
    - name: Check for files that should be gitignored
      run: |
        FOUND=$(git ls-files -- 'docs/*/runs/' 'docs/*/*/runs/' 'tmp/ui_audit_artifacts/' 'tmp/reference_captures/' 'tmp/reference_artifacts/' 2>/dev/null | head -5)
        if [ -n "$FOUND" ]; then
          echo "::error::Files tracked that should be gitignored:" && echo "$FOUND" && exit 1
        fi
    ```

14. **Re-run periodically** — invoke `/repo-cleanup` to discover new candidates as the repo evolves.
