# Tasks: 005 — Harness as Knowledge Layer + AST Search

## Problem Statement

Reposition Forge from a self-contained implementation pipeline into a tool-agnostic knowledge layer. Three work streams: (1) prune pipeline-owning files, (2) add a context handoff mechanism for external tools like Speckit, (3) add AST search as a new skill/command backed by ast-grep, called by find-reuse.

---

## Task List

| ID | Title | Type | Depends on | Acceptance criteria |
|---|---|---|---|---|
| T-001 | Delete forge.tasks.md command | `deletion` | — | `.claude/commands/forge.tasks.md` does not exist in the repo |
| T-002 | Delete forge.clarify.md command | `deletion` | — | `.claude/commands/forge.clarify.md` does not exist in the repo |
| T-003 | Delete forge.implement.md command | `deletion` | — | `.claude/commands/forge.implement.md` does not exist in the repo |
| T-004 | Delete forge.plan.md command | `deletion` | — | `.claude/commands/forge.plan.md` does not exist in the repo |
| T-005 | Delete task-decomposition skill directory | `deletion` | — | `.claude/skills/task-decomposition/` directory does not exist in the repo |
| T-006 | Delete clarify-spec skill directory | `deletion` | — | `.claude/skills/clarify-spec/` directory does not exist in the repo |
| T-007 | Delete implement-plan skill directory | `deletion` | — | `.claude/skills/implement-plan/` directory does not exist in the repo |
| T-008 | Delete implementer.md subagent | `deletion` | — | `.claude/agents/implementer.md` does not exist in the repo |
| T-009 | Delete canonical-source-guard.sh hook | `deletion` | — | `.claude/hooks/canonical-source-guard.sh` does not exist in the repo |
| T-010 | Update doc-index.json — remove 6 pipeline entries | `config` | T-001, T-002, T-003, T-005, T-006, T-007 | `.claude/doc-index.json` contains no entries with paths matching forge.tasks, forge.clarify, forge.implement, task-decomposition, clarify-spec, or implement-plan |
| T-011 | Update README.md — prune pipeline entries and counts | `docs-only` | T-001, T-002, T-003, T-004, T-005, T-006, T-007, T-008 | README.md states "Eleven skills" and "Eleven slash commands" with no references to the deleted pipeline components; includes migration note pointing to Speckit |
| T-012 | Update forge-blog.md — counts, pipeline retraction, pivot note | `docs-only` | T-001, T-002, T-003, T-005, T-006, T-007 | forge-blog.md skill list contains 11 entries, commands table is reduced to 11 rows, and a knowledge-layer pivot note is present |
| T-013 | Bump forge.sh VERSION to 0.4.0 | `script` | — | `grep VERSION scripts/forge.sh` shows `VERSION="0.4.0"` |
| T-014 | Update detect-stack.sh — add ast_search_tool detection | `script` | — | After running detect-stack.sh, `.claude/stack.json` contains an `ast_search_tool` key with value `"ast-grep"`, `"semgrep"`, or `null` |
| T-015 | Create ast-search skill SKILL.md | `skill` | T-014 | The ast-search skill can be invoked by name in a Claude Code session and reads `ast_search_tool` from stack.json to select the search binary |
| T-016 | Create ast-search references/pattern-syntax.md | `docs-only` | T-015 | The file exists at `.claude/skills/ast-search/references/pattern-syntax.md` with pattern examples for JS/TS, Python, and Go |
| T-017 | Create forge.ast-search.md command | `command` | T-015 | `/forge.ast-search <pattern>` is available in the slash-command menu and returns `file:line` structural matches |
| T-018 | Update find-reuse SKILL.md — add ast-search pass | `skill` | T-015 | `/forge.find-reuse <term>` when ast-grep is available returns a merged result set from ripgrep text matches and ast-search structural matches, deduplicated and ranked |
| T-019 | Create forge.context.md command | `command` | — | `/forge.context` writes `.forge/context-snapshot.json` containing stack.json contents, stale doc entries, and path to the most recent `.forge/*/research.md` |
| T-020 | Create speckit-context-inject.sh hook | `hook` | T-019 | When a `/speckit.*` command fires, the hook's `additionalContext` output includes the current stack summary and stale doc count |
| T-021 | Create INTEGRATING.md | `docs-only` | T-019, T-020 | `INTEGRATING.md` exists at repo root documenting the context-snapshot.json protocol, file locations, and the UserPromptExpansion hook pattern |
| T-022 | Update doc-index.json — add entries for new files | `config` | T-010, T-015, T-016, T-017, T-018, T-019, T-020, T-021 | `.claude/doc-index.json` contains entries for forge.context.md, forge.ast-search.md, ast-search/SKILL.md, speckit-context-inject.sh, and INTEGRATING.md |
| T-023 | Update README.md — add new commands/skills | `docs-only` | T-011, T-015, T-017, T-019 | README.md lists forge.context and forge.ast-search in the commands section, ast-search in the skills section, with final counts accurate |
| T-024 | Update forge-blog.md — add new commands/skills | `docs-only` | T-012, T-015, T-017, T-019 | forge-blog.md command table includes forge.context and forge.ast-search rows and the skills list includes ast-search |
| T-025 | Regenerate diagrams/01-architecture.svg | `docs-only` | T-011 | `diagrams/01-architecture.svg` no longer shows the pipeline layer; reflects the knowledge-layer-only architecture with the new context handoff surface |
| T-026 | Regenerate diagrams/05-find-reuse.svg | `docs-only` | T-018 | `diagrams/05-find-reuse.svg` shows the two-pass search flow: ripgrep text pass followed by ast-search structural pass, results merged and ranked |
| T-027 | Regenerate diagrams/07-knowledge-base.svg | `docs-only` | T-019, T-020 | `diagrams/07-knowledge-base.svg` reflects the context handoff model: Forge writes context-snapshot.json and injects additionalContext on Speckit command expansion |

---

## Routing Notes

**Behavior-changing tasks:** T-014 (detect-stack schema change), T-015 and T-018 (skill behavior), T-019 and T-020 (new command and hook — T-020 fires on every `/speckit.*` command so misconfiguration is highest-impact).

**Docs-only tasks:** T-011, T-012, T-016, T-021, T-023, T-024, T-025, T-026, T-027 (T-025/T-026/T-027 are SVG diagram regenerations — hand-crafted SVGs in `diagrams/`).

**Sequential constraints not in Depends-on column:**
- T-011 (prune README) must complete before T-023 (add new items to README) — same file, sequential edits.
- T-012 (prune blog) must complete before T-024 (add new items to blog) — same file, sequential edits.
- T-010 (remove doc-index entries) must complete before T-022 (add entries) — same file, avoid double-entry risk.
- T-014 must be verified (stack.json actually written with new key) before T-015 is authored — SKILL.md must reference the exact key name.

**Test coverage:** No automated test runner exists for skill/command/hook files. All acceptance criteria verified by inspection and manual Claude Code invocation.
