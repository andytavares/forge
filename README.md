# Forge

A cookiecutter Claude Code harness for large multi-language codebases. Drop it into any repo and you get a configured, opinionated environment for Claude Code: persistent rules, specialized subagents, on-demand skills, deterministic enforcement hooks, MCP wiring, and a knowledge-base layer anyone on the team can query.

## What you get

- **`CLAUDE.md`** template — short, signal-dense, repo-wide rules loaded every session.
- **`.claude/settings.json`** — sane allow/deny permission set + hook wiring.
- **`.mcp.json`** — MCP server config (filesystem + git out of the box, examples for the rest).
- **Seven subagents** — researcher, test-author, implementer, code-reviewer, doc-keeper, build-detective, codebase-oracle.
- **Twelve skills** — canonical-research, tdd-workflow, repo-conventions, find-reuse, code-review, doc-sync, codebase-stats, pattern-survey, build-audit, task-decomposition, clarify-spec, implement-plan.
- **Thirteen slash commands** — `/forge.detect-stack`, `/forge.plan`, `/forge.tdd`, `/forge.review`, `/forge.docs-sync`, `/forge.find-reuse`, `/forge.ask`, `/forge.stats`, `/forge.survey`, `/forge.audit`, `/forge.tasks`, `/forge.clarify`, `/forge.implement`.
- **Five hooks** — session-start, prompt-augment, pre-edit-guard (TDD, only enforced in tested packages), post-edit-format, post-edit-doc-mark.
- **`detect-stack.sh`** — writes `.claude/stack.json` so Claude always uses your real build commands.
- **`.claude-plugin/plugin.json`** — manifest so this can be distributed as a Claude Code plugin.
- **`forge.sh`** — interactive installer with install / update / uninstall / status / restore.

## Prerequisites

The installer needs: `bash`, `git`, `jq`, `find`, `rsync`. Most Linux/macOS systems have all of these; `jq` and `rsync` may need a `brew install` or `apt install`.

Claude Code itself: install per [the official quickstart](https://docs.claude.com/en/docs/claude-code/setup).

Optional but recommended:
- **`scc`** (or `tokei` / `cloc`) — for codebase statistics. Install via `brew install scc` or your package manager.
- The build/test tools for your stack (npm, pytest, go, cargo, bazel, etc.) — Forge uses whatever is already there.

## Install

From a clone of this scaffold:

```bash
# Interactive — recommended for first-time installs
./scripts/forge.sh
# choose 1 (Install), enter target path

# Non-interactive — for scripts and CI
./scripts/forge.sh install /path/to/your/repo
./scripts/forge.sh --yes install /path/to/your/repo   # auto-accept prompts
```

The installer:

1. Refuses to overwrite an existing install (asks if you want to `update` instead).
2. Shows you exactly what it will install before doing anything.
3. Copies managed files into `<target>/.claude/`, `<target>/.claude-plugin/`, `<target>/.mcp.json`, `<target>/scripts/`.
4. Creates `<target>/CLAUDE.md` from the template only if missing — never overwrites your existing one.
5. Runs `detect-stack.sh` against the target so `.claude/stack.json` is populated immediately.
6. Writes `.forge-manifest.json` so future updates know what's managed.

## Update

When new versions of Forge are released, pull the latest scaffold and run:

```bash
./scripts/forge.sh update /path/to/your/repo
# or non-interactively:
./scripts/forge.sh --yes update /path/to/your/repo
```

What update does:

1. Snapshots every managed file into `<target>/.forge-backups/<timestamp>/` before changing anything.
2. Shows you a diff summary of what will change.
3. Rsyncs the new versions of the managed paths (`--delete` so removed files in the new version are removed in the target).
4. **Never touches** `CLAUDE.md`, `.claude/doc-index.json`, or `.claude/stack.json` — those are yours.
5. If `.mcp.json` has been edited locally, writes the new version as `.mcp.json.new` and warns you to merge by hand.
6. Updates the manifest with the new version and timestamp.

You can always roll back with `./scripts/forge.sh restore /path/to/your/repo <backup-dir>`.

## Uninstall

```bash
./scripts/forge.sh uninstall /path/to/your/repo
./scripts/forge.sh --yes uninstall /path/to/your/repo
```

Uninstall:

1. Takes a final backup of all managed files into `.forge-backups/<timestamp>/`.
2. Removes only the managed paths — `CLAUDE.md`, `.claude/doc-index.json`, `.claude/stack.json` and the backups directory are preserved.
3. Removes the manifest.

If you want a clean slate, delete `.forge-backups/`, `CLAUDE.md`, and the leftover empty directories yourself.

## Status

```bash
./scripts/forge.sh status /path/to/your/repo
```

Prints the manifest (version, source, install date) and lists every managed path with a check or warning.

## What's managed vs. what's yours

| Path | Behavior on install | Behavior on update | Behavior on uninstall |
|---|---|---|---|
| `.claude/agents/` | Overwritten | Overwritten | Removed |
| `.claude/skills/` | Overwritten | Overwritten | Removed |
| `.claude/commands/` | Overwritten | Overwritten | Removed |
| `.claude/hooks/` | Overwritten | Overwritten | Removed |
| `.claude/settings.json` | Overwritten | Overwritten | Removed |
| `.claude-plugin/plugin.json` | Overwritten | Overwritten | Removed |
| `.mcp.json` | Written if missing | Written as `.mcp.json.new` if local edits exist | Removed |
| `scripts/detect-stack.sh` | Overwritten | Overwritten | Removed |
| `scripts/forge.sh` | Overwritten | Overwritten | Removed |
| `CLAUDE.md` | **Written if missing only** | **Never touched** | **Preserved** |
| `.claude/doc-index.json` | Created empty if missing | **Never touched** | **Preserved** |
| `.claude/stack.json` | Auto-generated | Re-run via `/forge.detect-stack` | **Preserved** |
| `.forge-backups/` | n/a | Snapshots added | **Preserved** |

## First-run checklist

After install, do these three things:

1. **Edit `CLAUDE.md`.** Replace `{{REPO_NAME}}` and `{{LANGUAGES}}` with real values. Add any team-wide non-negotiable rules (max ~200 lines total — every line is loaded on every request).
2. **Review `.mcp.json`.** The default ships filesystem + git MCP servers. Uncomment / add servers your team actually uses (Linear, Sentry, internal docs portal, etc.).
3. **Open Claude Code in the repo** and try a few commands:
   - `/forge.detect-stack` — verify it detected your real build commands.
   - `/forge.stats` — confirm you can get an honest line count.
   - `/forge.ask how does authentication work in this codebase?` — verify the oracle answers.
   - `/forge.find-reuse "url parsing helper"` — verify the reuse skill works.
   - `/forge.plan add a /healthz endpoint to the gateway` — verify the researcher produces a plan without writing code.

If any of these fail, run `/forge.detect-stack` first; most issues stem from a missing or stale `stack.json`.

## Feature workflow (tasks → clarify → implement)

Three slash commands provide a structured, spec-to-code pipeline for larger features:

```bash
# 1. Decompose a feature spec into a numbered task list
/forge.tasks "add rate limiting to the API gateway"

# 2. Interactively resolve ambiguities in the task list
/forge.clarify

# 3. Execute the task list in an isolated worktree
/forge.implement
```

What each command does:

- **`/forge.tasks <spec>`** — runs the `researcher` subagent against the spec, then the `task-decomposition` skill to generate a structured, dependency-ordered task list. Writes it to `.forge/NNN-slug/tasks.md` after your approval.
- **`/forge.clarify [NNN]`** — runs the `clarify-spec` skill to find every place a downstream implementer would face an arbitrary choice. Presents ambiguities one at a time and records your answers in `.forge/NNN-slug/clarifications.md`.
- **`/forge.implement [NNN]`** — runs the `implement-plan` skill to validate the task graph, resolves routing (TDD vs. implementer-direct, doc-sync needed), then executes tasks in order in a git worktree at `.worktrees/NNN-slug/`. Each task pauses for approval before the next. Full `code-reviewer` pass at the end.

The `.forge/` folder (spec, tasks, clarifications) is committed. The `.worktrees/` folder is gitignored — merge the feature branch when you're satisfied.

## Releasing updates to your team

The expected flow:

1. Maintain the scaffold in its own git repo (e.g., `your-org/forge`).
2. Tag releases with semver. Bump `VERSION="..."` in `scripts/forge.sh` to match.
3. Engineers in target repos pull the new scaffold and run `forge.sh update <their-repo>`.
4. The backup ensures any divergence (custom hooks, edited settings) can be reconciled or restored.

For internal distribution as a Claude Code **plugin** instead of a scaffold: see [Create and distribute a plugin marketplace](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces). Put a `marketplace.json` in a repo that lists this scaffold, and engineers install with `/plugin marketplace add your-org/marketplace-repo` then `/plugin install forge`.

## CI and headless mode

Forge works the same in headless mode. Common patterns:

```bash
# Pre-commit hook — review the staged diff
git diff --staged | claude -p --bare \
  "Run /forge.review on this diff. Exit nonzero if you would request changes."

# Nightly doc sync
claude -p --bare "Run /forge.docs-sync. Open a PR if there are updates."

# CI knowledge-base check
echo "Audit our bazel python build performance and recommend the top 3 fixes." \
  | claude -p --bare --output-format json | jq '.result'
```

## See also

- `forge-blog.md` — long-form write-up of the design choices.
- `diagrams/` — architecture and flow diagrams referenced from the blog.
- `.claude/agents/codebase-oracle.md` — the knowledge-base subagent (worth reading).
- `.claude/hooks/pre-edit-guard.sh` — the TDD enforcement (only fires in packages that already have tests).
