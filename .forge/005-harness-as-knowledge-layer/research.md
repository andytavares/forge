# Research: Harness as Knowledge Layer

**Date:** 2026-05-31
**Requested by:** Andrew
**Codebase context:** The Forge harness (v0.3.0) ships 15 slash commands, 14 skills, 7 subagents, and 6 hooks. It is organized around two distinct concerns: (1) a knowledge layer — session-start context injection, stack detection, doc-index tracking, find-reuse enforcement, research, review, TDD, and survey primitives — and (2) a self-contained implementation pipeline — `forge.tasks`, `forge.clarify`, `forge.implement`, the `task-decomposition`, `clarify-spec`, and `implement-plan` skills, and git worktree management. These two concerns share the same installer manifest and are indistinguishable to the update mechanism. Crucially, all six hooks are already pipeline-agnostic — none reference `.forge/NNN-slug/` or any pipeline construct.

---

## Problem Statement

Andrew wants to reposition Forge from a tool that owns the full feature-delivery pipeline (spec → tasks → clarify → implement → worktree) into a tool that turns any codebase into a queryable knowledge base and injects that knowledge into whatever implementation system the team already uses — in Andrew's case, Speckit (github/spec-kit). The pipeline commands duplicate what Speckit already does well, while the knowledge-layer commands (research, review, find-reuse, stats, survey, TDD, docs-sync, detect-stack) are genuinely complementary. The redesign should make Forge tool-agnostic so that session context, doc-index, stack.json, and skills are consumable surfaces for any implementation tool.

---

## Scope

**In scope:**
- Categorizing the existing harness into pipeline-owning vs knowledge-layer components
- Defining the cost of removing pipeline components (doc-debt, installer impact)
- Three architectural options for the knowledge-layer model
- Hook and MCP surfaces available for tool-agnostic context handoff

**Out of scope:**
- Writing implementation code
- Designing Speckit itself
- Evaluating non-Forge aspects of the user's toolchain

---

## Codebase Context

### Commands — pipeline-owning (candidates for removal)

- `/forge.tasks` — `.claude/commands/forge.tasks.md:1-19`. Creates `.forge/NNN-slug/`, calls `task-decomposition` skill, writes `tasks.md`. Explicitly chains to `/forge.clarify`.
- `/forge.clarify` — `.claude/commands/forge.clarify.md:1-23`. Calls `clarify-spec` skill, writes `clarifications.md`. Explicitly chains to `/forge.implement`.
- `/forge.implement` — `.claude/commands/forge.implement.md:1-29`. Creates a git worktree at `.worktrees/NNN-slug/`, runs `implement-plan` skill, routes tasks through TDD/implementer/code-reviewer/docs-sync.

### Commands — knowledge/utility (keep)

`/forge.research`, `/forge.ask`, `/forge.detect-stack`, `/forge.docs-sync`, `/forge.find-reuse`, `/forge.review`, `/forge.stats`, `/forge.survey`, `/forge.tdd`, `/forge.constitution`, `/forge.plan`, `/forge.audit`

Note: `/forge.plan` (`.claude/commands/forge.plan.md:1-5`) is a thin wrapper — "Run the researcher subagent for: $ARGUMENTS / Return only the plan. Do not start editing." It is a knowledge primitive, not a pipeline command.

### Skills — pipeline-owning (candidates for removal)

- `task-decomposition` — `.claude/skills/task-decomposition/SKILL.md`. Converts spec to T-NNN task list with dependency graph and routing fields.
- `clarify-spec` — `.claude/skills/clarify-spec/SKILL.md`. Scans a task list for ambiguities.
- `implement-plan` — `.claude/skills/implement-plan/SKILL.md`. Validates DAG, resolves routing fields, produces per-task routing plan.

### Skills — knowledge/utility (keep)

`canonical-research`, `tdd-workflow`, `repo-conventions`, `find-reuse`, `code-review`, `doc-sync`, `codebase-stats`, `pattern-survey`, `build-audit`, `project-constitution`, `research-topic`

### Subagents — pipeline-specific (candidate for removal)

- `implementer.md` — `.claude/agents/implementer.md:1-24`. "Use after the test-author has written failing tests. Writes the minimum implementation to make the tests pass." Referenced only via the pipeline's routing logic. Without the pipeline, it has no natural invocation path.

### Subagents — universally useful (keep)

`researcher`, `test-author`, `code-reviewer`, `doc-keeper`, `build-detective`, `codebase-oracle`

### Hooks — all pipeline-agnostic (keep all)

Every hook is already pipeline-agnostic. None reference `.forge/NNN-slug/` or any pipeline construct:

- `session-start.sh` — Injects repo HEAD, branch, stack.json summary, stale-doc count, project constitution.
- `post-compact.sh` — Reinjects constitution after context compaction.
- `prompt-augment.sh` — Detects build/create intent and injects find-reuse reminder.
- `pre-edit-guard.sh` — TDD enforcement in tested packages.
- `post-edit-format.sh` — Runs formatter from `stack.json` on the edited file.
- `post-edit-doc-mark.sh` — Bumps `staleness_score` in `doc-index.json` when a referenced path is edited.
- `canonical-source-guard.sh` — Deprecated stub (exit 0). Safe to delete.

### Installer behavior

`scripts/forge.sh:100-117` — `forge_source_files()` walks `.claude/agents`, `.claude/skills`, `.claude/commands`, `.claude/hooks` at install/update time. **Removing pipeline files from the source tree automatically removes them from the installer manifest** — no separate manifest surgery needed.

### Doc-index pipeline entries (`.claude/doc-index.json`)

6 of 13 entries reference pipeline-specific files:
- `.claude/commands/forge.tasks.md` (lines 58-67)
- `.claude/commands/forge.clarify.md` (lines 69-78)
- `.claude/commands/forge.implement.md` (lines 80-90)
- `.claude/skills/task-decomposition/SKILL.md` (lines 91-100)
- `.claude/skills/clarify-spec/SKILL.md` (lines 101-111)
- `.claude/skills/implement-plan/SKILL.md` (lines 112-124)

Plus 2 entries (README, blog) that reference pipeline counts/names in their summaries.

---

## Options Considered

### Option 1: Prune-in-place

Remove the pipeline-owning files from the source tree. No new architecture required; the harness becomes a knowledge layer by subtraction.

**What is removed:** `forge.tasks.md`, `forge.clarify.md`, `forge.implement.md`, `task-decomposition/`, `clarify-spec/`, `implement-plan/`, `implementer.md`

**What is kept:** All 6 hooks, 12 commands, 11 skills, 6 subagents, `stack.json`, `doc-index.json`, project constitution, session-start context injection.

**Doc-debt:** 6 doc-index entries deleted. `README.md` command/skill counts corrected. `forge-blog.md` pipeline sections need a pruning pass.

**Official source:**
Source: Claude Code Hooks Reference — https://docs.anthropic.com/en/docs/claude-code/hooks
Quote: "Hooks allow you to run shell commands at specific points in Claude Code's lifecycle."

**Feasibility:** High. The pipeline is cleanly encapsulated in its own files. Removal is a bounded, mechanical operation.

**Complexity to adopt:** Low.

**Risks:**
- `implementer.md` is orphaned if pipeline commands are removed but the agent file is left behind. Must be removed or rewritten.
- Removal is irreversible without a new commit. Users who built workflows around `forge.tasks`/`forge.clarify`/`forge.implement` need a migration note.

**Codebase fit:** Excellent. The installer handles removal automatically.

---

### Option 2: Speckit-aware Integration Layer

Keep Option 1's pruning and add Speckit-specific context injection.

**What Speckit actually is (verified):**

Source: github/spec-kit README — https://github.com/github/spec-kit
Quote: "Spec-Driven Development flips the script on traditional software development... specifications become executable."

Spec-kit (the `specify` CLI, published by GitHub) is an open-source toolkit for Spec-Driven Development. It exposes its workflow to AI coding agents — including Claude Code — through slash commands such as `/speckit.constitute` and `/speckit.specify`, and through an agent skills mode. It supports 30+ coding agents including Claude Code, GitHub Copilot, Gemini CLI, and Cursor.

**Integration surface — confirmed facts:**

- Speckit writes to and reads from a `.specify/` directory tree: `constitution.md`, `templates/`, `presets/`, `extensions/`, and `specs/<feature-id>/` artifacts (`spec.md`, `plan.md`, `tasks.md`, `contracts/`).
- It writes a `CLAUDE.md` file (via template) to guide Claude during planning and implementation phases.
- It does **not** read Forge's `stack.json`, `doc-index.json`, or project constitution out of the box.
- It does **not** expose MCP tools or Claude Code hooks of its own.
- It runs **inside** Claude Code's context window (as slash commands and skills), which means Claude Code's `UserPromptExpansion` hook fires in the same session where Speckit commands execute.

**Concrete integration paths available:**

1. **`UserPromptExpansion` hook injection.** When a `/speckit.*` command fires, Forge's hook can append `additionalContext` with current stack, stale doc count, and open research briefs. Speckit receives this context without modification.

   Source: Claude Code Hooks Reference — https://docs.anthropic.com/en/docs/claude-code/hooks
   Quote: "additionalContext: Text injected into Claude's context" (universal output field, present on UserPromptExpansion events)

2. **CLAUDE.md merge.** Forge's session-start hook already writes project constitution and stack summary into the context. A Forge command could generate a Speckit-compatible `CLAUDE.md` section including stack.json summary, stale-doc warnings, and find-reuse state — which Speckit picks up naturally because it reads CLAUDE.md.

3. **`.specify/` context snapshot.** A Speckit preset or extension could be authored to read Forge's `.forge/context-snapshot.json` during spec generation — but this requires authoring a Speckit extension, which is out of scope for Forge alone.

**Feasibility:** Medium. Hook injection and CLAUDE.md merge are low-code additions to existing Forge infrastructure. The Speckit extension path requires work outside Forge.

**Complexity to adopt:** Medium (hook injection) to High (extension path).

**Risks:**
- Speckit does not document a stability guarantee on its slash command schema. Hook injection based on pattern-matching `/speckit.*` could break if Speckit renames commands.
- CLAUDE.md is a shared file — a dedicated Forge section with a clear delimiter would prevent conflicts if Speckit also writes CLAUDE.md at init time.
- This option is Speckit-specific; if Andrew switches implementation tools, the integration is not reusable.

**Codebase fit:** Good for hook-based paths (hooks already exist and are pipeline-agnostic). Neutral for CLAUDE.md merge.

---

### Option 3: Tool-agnostic Context Protocol

Keep Option 1's pruning and define a standard context handoff — structured file outputs and hook injection points that any implementation tool can consume. Four sub-variants, in order of increasing complexity:

**A. File-based handoff (zero new code).** `stack.json` and `doc-index.json` already exist. Research briefs already land in `.forge/NNN-slug/research.md`. Adding a single `.forge/context-snapshot.json` aggregating stack, doc-index, and the latest research brief gives any tool one integration point.

**B. Hook-based injection.** Detect intent in `UserPromptExpansion` and inject a compact context block (stack, stale docs, last research brief). Already used by `prompt-augment.sh`.

Source: Claude Code Hooks Reference — https://docs.anthropic.com/en/docs/claude-code/hooks
Quote: "additionalContext: Context added to Claude's window" (UserPromptSubmit output envelope field)

**C. MCP-based handoff.** Register a local stdio MCP server in `.mcp.json` exposing Forge's knowledge layer as MCP tools — `forge/stack`, `forge/find-reuse`, `forge/doc-index`.

Source: Claude Code MCP Reference — https://docs.anthropic.com/en/docs/claude-code/mcp
Quote: "Claude Code sets CLAUDE_PROJECT_DIR in the spawned server's environment to the project root, so your server can resolve project-relative paths without depending on the working directory."

**D. Prompt-convention protocol (zero code).** Define a convention: any implementation tool that wants Forge context begins its prompt with a `@forge:context` header. A `UserPromptSubmit` hook detects this header and injects the context block. No MCP server, no file polling — just a prompt convention.

**Feasibility:** High for A and D; Medium for B; Medium-high for C.

**Complexity to adopt:** Low (A, D) to Medium (B, C).

**Risks:**
- The MCP server variant (C) requires ongoing maintenance as a new runtime component.
- Speckit runs as slash commands inside Claude Code's session (confirmed above), so hook variants B and D are directly applicable to Speckit without any Speckit-specific code.

**Codebase fit:** Excellent — extends established hook and file patterns already in the harness.

---

## Comparison Table

| Criterion | Option 1: Prune-in-place | Option 2: Speckit-aware | Option 3: Tool-agnostic protocol |
|---|---|---|---|
| Official docs quality | High (Claude Code docs) | High (github/spec-kit README verified) | High (Claude Code hooks + MCP) |
| Feasibility | High | Medium (hook/CLAUDE.md paths viable) | High (file/hook variants) |
| Complexity | Low | Medium | Low–Medium |
| Codebase fit | Excellent | Good (hook paths) | Excellent |
| Key risk | Irreversible without a commit | Speckit command schema not stability-guaranteed | MCP variant adds a runtime component |
| Tool-agnosticism | Yes (by omission) | No (Speckit-specific) | Yes (by design) |

---

## Recommendation

**Option 3 (Tool-agnostic context protocol), starting with the file-based variant (A) and prompt-convention variant (D), with Option 1's pruning as an immediate prerequisite.**

1. **The pruning is safe and automatic.** `forge_source_files()` (`scripts/forge.sh:100-117`) walks the source tree at install time. Removing pipeline files from source automatically removes them from the manifest. All six hooks survive intact.

2. **File-based handoff is 80% live.** `stack.json`, `doc-index.json`, and `.forge/NNN-slug/research.md` already exist. The only missing piece is a single aggregated context snapshot — a one-file addition.

3. **Option 2 is now assessable but still not the right first move.** Speckit runs as slash commands inside Claude Code's session, which means Option 3D (hook injection detecting `/speckit.*` command expansion) already covers the Speckit case without Speckit-specific coupling. A Speckit-specific Option 2 layer would add fragile coupling for no functional benefit over Option 3D.

4. **Option 3D (prompt convention) is free.** Documenting the convention "begin your Speckit spec with a `@forge:context` header and Forge will inject current stack + stale docs" costs nothing and immediately makes Forge useful to Speckit and any other tool.

**Trade-off accepted:** Forge becomes a passive knowledge layer rather than an active pipeline. Users who relied on `forge.tasks`/`forge.implement` must migrate to their preferred tool. This is correct given Andrew already has Speckit for that purpose.

---

## Open Questions — All Resolved

1. ~~**What is Speckit's integration surface?**~~ — **CLOSED.** Speckit (github/spec-kit) is a CLI + slash commands/skills running inside Claude Code's session. Hook-based injection via `UserPromptExpansion` is the lowest-coupling integration path.

2. ~~**Remove or repurpose `implementer.md`?**~~ — **CLOSED: Remove.** Remove `implementer.md` with the rest of the pipeline files.

3. ~~**What should the context snapshot format be?**~~ — **CLOSED: Go with the recommendation** (Option 3A file-based + 3D prompt-convention). Add `/forge.context` command and document the protocol.

4. ~~**Is `/forge.plan` superseded by `/forge.research`?**~~ — **CLOSED: Yes. Remove `/forge.plan`.** `/forge.research` replaces it with a richer five-phase protocol and a durable file output.

5. ~~**Versioning strategy?**~~ — **CLOSED: Bump to next minor (v0.4.0).** Removal of pipeline commands is a breaking change; a minor bump signals intentional scope narrowing.

---

## Next Steps

1. **Prune pipeline files** — delete `forge.tasks.md`, `forge.clarify.md`, `forge.implement.md`, `task-decomposition/`, `clarify-spec/`, `implement-plan/`, `implementer.md`.
2. **Update doc-index** — remove 6 pipeline entries; update README command/skill counts; add migration note to `forge-blog.md`.
3. **Add `/forge.context` command** — writes `.forge/context-snapshot.json` aggregating stack + doc-index + latest research brief.
4. **Document the protocol** — add `INTEGRATING.md` describing file-based context handoff. Include the `UserPromptExpansion` hook pattern for Speckit: detect `/speckit.*` command expansion, inject `additionalContext` with stack + stale docs + last research brief.
5. **Wire `UserPromptExpansion` hook for Speckit** — one new hook script, pattern-matches on `/speckit.*`, injects the context snapshot. This makes Option 3D live for Speckit without any Speckit-side changes.
6. **Defer Speckit extension path** — the `.specify/` preset/extension approach requires authoring and maintaining a Speckit extension. Revisit only if hook-based injection proves insufficient.
