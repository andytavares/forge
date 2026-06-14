# Feature 001: Project Constitution System

<!-- No reuse candidates for: interactive authoring flow, PostCompact hook, constitution schema.
     Reuse candidates found for:
       - post-compact.sh JSON envelope → .claude/hooks/prompt-augment.sh:18-20 (same pattern, reuse)
       - session-start.sh extension → .claude/hooks/session-start.sh (extend, not replace)
-->

---

## T-001 — Create constitution slash command definition

**Title:** Create constitution slash command definition
**Description:** Define the `/forge-constitution` slash command as a markdown file in `.claude/commands/`. The command delegates to the `project-constitution` skill, handles the create-vs-update branching (does the file exist?), and instructs Claude to remind the user to commit the result.
**Acceptance criteria:**
1. Running `/forge-constitution` in a session where no `.forge/constitution.md` exists causes Claude to enter the interactive authoring flow described in the `project-constitution` skill.
2. Running `/forge-constitution` when `.forge/constitution.md` already exists causes Claude to display the current contents and offer "Update a section / Regenerate from scratch / Cancel" before making any changes.
**Depends on:** (none)
**Tags:** `config`
**Touches tested package:** no
**Touches documented module:** yes

---

## T-002 — Create project-constitution authoring skill

**Title:** Create project-constitution authoring skill
**Description:** Write `.claude/skills/project-constitution/SKILL.md` defining the interactive, LLM-assisted authoring flow. The skill must specify: scan the repo for signals via the `researcher` subagent, draft each H2 section, present one section at a time (Accept / Edit / Skip), assemble the full file, confirm with the user, then write `.forge/constitution.md`. Include the required constitution schema (six H2 sections) and the rule that any section may contain `(none)`.
**Acceptance criteria:**
1. After completing the skill flow, `.forge/constitution.md` exists on disk and contains all six required H2 headings (`## Purpose`, `## Non-negotiables`, `## Architectural principles`, `## Risk posture`, `## Team conventions`, `## Out of scope`).
2. Skipping every section during the flow still produces a valid file where each section body is `(none)` rather than empty or absent.
3. The user is shown a full preview of the assembled file and asked to confirm before any write occurs.
**Depends on:** T-001
**Tags:** `config`
**Touches tested package:** no
**Touches documented module:** yes

---

## T-003 — Extend session-start hook to inject constitution

**Title:** Extend session-start hook to inject constitution
**Description:** Append a constitution-injection block to `.claude/hooks/session-start.sh`. If `.forge/constitution.md` exists, emit its full contents wrapped in `=== project-constitution ===` / `=== end project-constitution ===` delimiters on stdout. If it does not exist, emit a single advisory line. Add a character-count guard: if the file exceeds 2000 characters, emit a warning instead of the full content and tell the user to trim it.
**Acceptance criteria:**
1. When `.forge/constitution.md` exists and is ≤ 2000 characters, the session-start hook stdout includes the exact text `=== project-constitution ===` followed by the file contents and then `=== end project-constitution ===`.
2. When `.forge/constitution.md` does not exist, the hook exits cleanly (exit code 0) and emits exactly one line containing the phrase "run /forge-constitution".
3. When `.forge/constitution.md` exceeds 2000 characters, the hook emits a warning mentioning the character limit and does not emit the full file contents.
**Depends on:** (none)
**Tags:** `config`
**Touches tested package:** no
**Touches documented module:** yes

---

## T-004 — Create post-compact hook for constitution reinjection

**Title:** Create post-compact hook for constitution reinjection
**Description:** Write `.claude/hooks/post-compact.sh`. When context compaction fires, this hook reads `.forge/constitution.md` and emits it as the `additionalContext` field inside the `hookSpecificOutput` JSON envelope (reusing the exact pattern from `prompt-augment.sh`). If the file is absent, write a single stderr warning and exit 0. The hook must be executable.
**Acceptance criteria:**
1. When `.forge/constitution.md` exists, the hook writes valid JSON to stdout matching the shape `{ "hookSpecificOutput": { "hookEventName": "PostCompact", "additionalContext": "<file contents>" } }`.
2. When `.forge/constitution.md` is absent, the hook exits with code 0 and writes nothing to stdout (warning goes to stderr only).
**Depends on:** (none)
**Tags:** `config`
**Touches tested package:** no
**Touches documented module:** yes

---

## T-005 — Wire PostCompact hook in settings.json

**Title:** Wire PostCompact hook in settings.json
**Description:** Add a `PostCompact` entry to the `hooks` object in `.claude/settings.json` pointing to `.claude/hooks/post-compact.sh`. The entry must follow the same structure as the existing `SessionStart` entry.
**Acceptance criteria:**
1. `.claude/settings.json` is valid JSON after the change (parseable by `jq`).
2. The `hooks.PostCompact` array contains exactly one entry with `type: "command"` and `command: ".claude/hooks/post-compact.sh"`.
**Depends on:** T-004
**Tags:** `config`
**Touches tested package:** no
**Touches documented module:** yes

---

## T-006 — Add constitution sentinel to CLAUDE.md

**Title:** Add constitution sentinel to CLAUDE.md
**Description:** Add a new numbered step to the "Always do this first" section of `CLAUDE.md` instructing Claude to treat any `=== project-constitution ===` block in its context as top-level non-negotiables for the session, and to warn the user once (and suggest running `/forge-constitution`) if the block is absent.
**Acceptance criteria:**
1. `CLAUDE.md` contains a step under "Always do this first" that references `=== project-constitution ===` by name.
2. The step instructs Claude to warn and suggest `/forge-constitution` when the block is absent.
**Depends on:** T-003
**Tags:** `docs-only`
**Touches tested package:** no
**Touches documented module:** yes

---

## T-007 — Update forge.sh installer for constitution paths

**Title:** Update forge.sh installer for constitution paths
**Description:** In `scripts/forge.sh`, add `.forge/constitution.md` to `list_user_owned_paths()` (never overwrite on install/update) and add `.claude/hooks/post-compact.sh` to `list_managed_paths()` (installed and updated by the harness). No other changes to installer logic are needed.
**Acceptance criteria:**
1. Running `grep` on `list_user_owned_paths` output includes `.forge/constitution.md`.
2. Running `grep` on `list_managed_paths` output includes `.claude/hooks/post-compact.sh`.
3. The `forge.sh` script passes `bash -n` (syntax check) after the change.
**Depends on:** T-004
**Tags:** `config`
**Touches tested package:** no
**Touches documented module:** yes

---

## T-008 — Add doc-index entries for constitution files

**Title:** Add doc-index entries for constitution files
**Description:** Add two entries to `.claude/doc-index.json`: one for `.claude/commands/forge-constitution.md` (the command definition) and one for `.forge/constitution.md` (the constitution itself). Each entry must include `path`, `title`, `summary`, `owners`, `referenced_code_paths`, `last_verified_commit`, and `staleness_score: 0`.
**Acceptance criteria:**
1. `.claude/doc-index.json` is valid JSON after the change.
2. The file contains an entry with `"path": ".claude/commands/forge-constitution.md"`.
3. The file contains an entry with `"path": ".forge/constitution.md"`.
**Depends on:** T-001, T-002
**Tags:** `config`
**Touches tested package:** no
**Touches documented module:** yes
