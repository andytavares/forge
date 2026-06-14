# Feature 003: Documentation Update — v0.2.0

---

## T-001 — Update README.md to v0.2.0 state

**Title:** Update README.md for all v0.2.0 changes
**Description:** Apply 10 targeted edits to README.md: correct component counts, remove rsync prerequisite, update install/update/uninstall/status descriptions for file-level ownership, replace the ownership table with the co-ownership model, add step 4 to first-run checklist, update feature workflow command descriptions to remove pause language, and add a Project Constitution section.
**Acceptance criteria:**
1. README.md states 13 skills, 14 slash commands, 6 hooks, 7 subagents, and lists /forge-constitution and post-compact.sh.
2. README.md does not mention rsync in prerequisites or describe rsync --delete in update behavior.
3. README.md has a "Project Constitution" section describing .forge/constitution.md, the authoring flow, and session injection.
4. The ownership table shows user files in shared dirs as "Never touched" on all operations.
**Depends on:** (none)
**Tags:** `docs-only`
**Touches tested package:** no
**Touches documented module:** yes

---

## T-002 — Update forge-blog.md to v0.2.0 state

**Title:** Update forge-blog.md for all v0.2.0 changes
**Description:** Apply 7 targeted edits to forge-blog.md: update CLAUDE.md description to five things, fix skill/hook/command counts, add project-constitution skill and post-compact hook to their tables, remove pause language from TDD and implement descriptions, rewrite installer section for file-level ownership, update the walkthrough step 1 for constitution injection. Add one new subsection "The project constitution" after the @file imports note.
**Acceptance criteria:**
1. forge-blog.md describes six hooks including post-compact.sh.
2. forge-blog.md describes thirteen skills including project-constitution.
3. forge-blog.md has a "The project constitution" subsection explaining the soul-file concept, dual injection (session-start + post-compact), and how it differs from CLAUDE.md.
4. forge-blog.md does not say "pausing for human approval between stages" or reference rsync --delete.
**Depends on:** (none)
**Tags:** `docs-only`
**Touches tested package:** no
**Touches documented module:** yes

---

## T-003 — Bump doc-index.json commit references

**Title:** Update doc-index.json last_verified_commit for changed docs
**Description:** Update last_verified_commit and reset staleness_score to 0 for the README.md, forge-blog.md, and CLAUDE.md entries in .claude/doc-index.json. The commit SHA should reflect the current HEAD after the doc edits land.
**Acceptance criteria:**
1. .claude/doc-index.json is valid JSON after the change.
2. The README.md entry has staleness_score: 0.
3. The forge-blog.md entry has staleness_score: 0.
**Depends on:** T-001, T-002
**Tags:** `config`
**Touches tested package:** no
**Touches documented module:** no
