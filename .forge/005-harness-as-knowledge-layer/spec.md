# Spec: 005 — Harness as Knowledge Layer + AST Search

## Summary

Reposition Forge from a self-contained implementation pipeline into a tool-agnostic knowledge layer that enhances whatever implementation system the user already uses (e.g. Speckit / github/spec-kit). This involves three work streams:

1. **Prune the implementation pipeline** — remove files that duplicate what external tools like Speckit already do
2. **Add a context handoff mechanism** — make Forge's knowledge artifacts consumable by any tool
3. **Add AST search** — a new `ast-search` skill/command backed by `ast-grep`, called by `find-reuse` for structural code search

Full research and all resolved open questions are in `.forge/005-harness-as-knowledge-layer/research.md`.

---

## Work Stream 1: Prune the Pipeline

### Files to delete

**Commands:**
- `.claude/commands/forge-tasks.md`
- `.claude/commands/forge-clarify.md`
- `.claude/commands/forge-implement.md`
- `.claude/commands/forge-plan.md` — superseded by `/forge-research`

**Skills:**
- `.claude/skills/task-decomposition/` (entire directory)
- `.claude/skills/clarify-spec/` (entire directory)
- `.claude/skills/implement-plan/` (entire directory)

**Subagents:**
- `.claude/agents/implementer.md`

**Hooks:**
- `.claude/hooks/canonical-source-guard.sh` — deprecated stub (exit 0), safe to delete

### Doc updates required after pruning

- `.claude/doc-index.json` — remove 6 pipeline entries (forge.tasks, forge.clarify, forge.implement, task-decomposition, clarify-spec, implement-plan); update README and forge-blog summaries
- `README.md` — update command count (15 → 11), skill count (14 → 11), remove pipeline entries from lists, add migration note pointing to Speckit
- `forge-blog.md` — update skill/command counts, remove or retract the pipeline sections, add a note about the knowledge-layer pivot
- `scripts/forge.sh` — bump VERSION from "0.3.0" to "0.4.0"

---

## Work Stream 2: Context Handoff

### New command: `/forge-context`

Add `.claude/commands/forge-context.md` — a command that writes `.forge/context-snapshot.json` aggregating:
- Current `stack.json` contents
- All `doc-index.json` entries with non-zero `staleness_score`
- Path to the most recent research brief under `.forge/`

This gives any external tool (Speckit, Cursor, a custom CLI) a single file to read for current codebase context.

### New hook: `UserPromptExpansion` for Speckit

Add `.claude/hooks/speckit-context-inject.sh` — a `UserPromptExpansion` hook that:
- Detects when a `/speckit.*` command is expanding
- Injects `additionalContext` containing the current stack summary, stale doc count, and path to the latest `.forge/*/research.md`

This requires no changes to Speckit — it receives Forge context through the standard Claude Code context window.

### New doc: `INTEGRATING.md`

Document the file-based context handoff protocol:
- What files exist (stack.json, doc-index.json, .forge/context-snapshot.json)
- Where they live and what they contain
- How an external tool reads them
- The `UserPromptExpansion` hook pattern for tools that run as Claude Code commands

---

## Work Stream 3: AST Search

### New skill: `ast-search`

Add `.claude/skills/ast-search/SKILL.md` — a skill that performs structural code search using `ast-grep` (primary) or `semgrep` (fallback). The skill:
- Reads the available AST tool from `stack.json` (populated by detect-stack)
- Takes a structural pattern and target language as input
- Returns ranked matches with `file:line` citations
- Falls back to a notice if neither tool is available

Add `.claude/skills/ast-search/references/pattern-syntax.md` — a reference for `ast-grep` pattern syntax for the most common languages (JS/TS, Python, Go).

### New command: `/forge-ast-search`

Add `.claude/commands/forge-ast-search.md` — exposes the `ast-search` skill as a slash command.

### Update: `find-reuse` skill

Edit `.claude/skills/find-reuse/SKILL.md` — after the text search (ripgrep) pass, call the `ast-search` skill for a structural search pass. Merge and deduplicate results before returning ranked candidates.

### Update: `detect-stack`

Edit `scripts/detect-stack.sh` — detect whether `ast-grep` or `semgrep` is available (`which ast-grep`, `which semgrep`) and write the result to `stack.json` under a new `ast_search_tool` key. If neither is available, write `null` and emit a warning.

---

## Acceptance Criteria (feature-level)

1. After applying this change, running `forge.sh install` on a clean repo installs no pipeline files (forge.tasks, forge.clarify, forge.implement, task-decomposition, clarify-spec, implement-plan, implementer.md).
2. `/forge-find-reuse <term>` returns both text-match and structural-match candidates when `ast-grep` is available.
3. `/forge-ast-search <pattern>` returns `file:line` matches for a structural pattern.
4. `.forge/context-snapshot.json` is written by `/forge-context` and contains stack, stale-doc list, and latest research brief path.
5. When a `/speckit.*` command fires in a Claude Code session with Forge installed, `additionalContext` is injected with current stack summary and stale doc count.
6. `README.md` and `forge-blog.md` reflect the new scope: knowledge layer, not pipeline.
