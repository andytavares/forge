# Integrating Forge with External Tools

Forge v0.4.0 is a knowledge layer. It turns any codebase into a queryable, structured knowledge base and injects that knowledge into whatever implementation tool you use — without requiring changes to that tool.

---

## Context artifacts (file-based handoff)

After installing Forge, three files are always available to any tool:

| File | Written by | Contents |
|---|---|---|
| `.claude/stack.json` | `detect-stack.sh` (on install + `/forge-detect-stack`) | Languages, build/test/lint/format commands, `ast_search_tool` |
| `.claude/doc-index.json` | Forge install; updated by `post-edit-doc-mark.sh` hook | All indexed markdown files with staleness scores |
| `.forge/context-snapshot.json` | `/forge-context` command | Aggregated snapshot: stack + stale docs + latest research brief path |
| `.forge/<NNN>-slug/research.md` | `/forge-research` command | Structured feasibility brief for a given topic |

Any tool that reads these files gets full Forge context without any API calls or hook wiring.

---

## Hook-based injection (Claude Code sessions)

If your implementation tool runs **inside a Claude Code session** (as a slash command or skill), Forge automatically injects context at the right moment via the `UserPromptSubmit` hook.

### How it works

`speckit-context-inject.sh` fires on every `UserPromptSubmit` event. It checks whether the prompt begins with `/speckit.*`. If yes, it injects `additionalContext` into Claude's context window:

```
[Forge context] Stack: typescript, go | ast-search: ast-grep | Stale docs: 2 | Latest research: .forge/005-harness-as-knowledge-layer/research.md
```

This requires no changes to Speckit or any other tool — it receives Forge context through the standard Claude Code context window.

### Adding support for other tools

To inject Forge context when a different tool's command fires, edit `.claude/hooks/speckit-context-inject.sh` and extend the detection regex:

```bash
# Current: only /speckit.*
if ! echo "$PROMPT" | grep -Eq '^\s*/speckit\.'; then

# Extended: /speckit.* or /cursor.* or /mytools.*
if ! echo "$PROMPT" | grep -Eq '^\s*/(speckit|cursor|mytools)\.'; then
```

---

## Speckit integration (github/spec-kit)

[Speckit](https://github.com/github/spec-kit) runs as slash commands and skills inside Claude Code's session. No Speckit-side changes are needed.

**Recommended workflow:**

```bash
# 1. Research before speccing
/forge-research "add rate limiting to the API gateway"

# 2. Export current context snapshot
/forge-context

# 3. Run Speckit — Forge context is injected automatically
/speckit.specify "add rate limiting to the API gateway"
```

When `/speckit.specify` fires, Forge's hook injects the current stack, stale doc count, and path to the latest research brief. Speckit uses this as context for its spec generation without any explicit wiring.

---

## Tool-agnostic protocol (any tool, any environment)

If your tool runs **outside Claude Code** (a separate CLI, CI job, web service), use the file-based handoff:

```bash
# Generate a fresh context snapshot
claude -p --bare "/forge-context"

# Your tool reads the snapshot
cat .forge/context-snapshot.json | jq '.stack.languages'
cat .forge/context-snapshot.json | jq '.stale_docs'
```

The snapshot is a stable JSON schema. Fields will not be removed without a major version bump.

---

## Context snapshot schema

`.forge/context-snapshot.json`:

```json
{
  "generated_at": "2026-05-31T12:00:00Z",
  "stack": {
    "languages": ["typescript", "go"],
    "build": { "commands": ["npm run build"] },
    "test": { "commands": ["npm test"], "command": "npm test" },
    "lint": { "commands": ["npm run lint"], "command": "npm run lint" },
    "format": { "commands": ["npm run format"] },
    "ast_search_tool": "ast-grep",
    "detected_at_commit": "abc1234",
    "detected_at": "2026-05-31T11:00:00Z"
  },
  "stale_docs": [
    { "path": "README.md", "staleness_score": 1, "title": "Forge — Claude Code harness" }
  ],
  "latest_research": ".forge/005-harness-as-knowledge-layer/research.md",
  "forge_version": "0.4.0"
}
```
