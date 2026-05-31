---
description: Execute a feature's task list in an isolated git worktree at .worktrees/NNN-slug/, routing each task to the correct workflow
---

Implement feature: $ARGUMENTS

If $ARGUMENTS is empty, use the highest-numbered folder in `.forge/`.
If $ARGUMENTS is a number (e.g. `001`), resolve it to the matching `.forge/NNN-*` folder.

1. Read `.forge/NNN-slug/tasks.md`. If it does not exist, stop: "Run /forge.tasks first."
2. Read `.forge/NNN-slug/clarifications.md` if it exists. If absent, note: "No clarifications found — proceeding with task list as-is. Run /forge.clarify NNN first if the spec has open questions."
3. Run the `implement-plan` skill to:
   - Validate the dependency graph (no cycles, no missing IDs).
   - Resolve any `Touches tested package: unknown` fields using `.claude/stack.json`.
   - Resolve any `Touches documented module: unknown` fields using `.claude/doc-index.json`.
   - Confirm every task flagged `AMBIGUOUS:` has a matching entry in `clarifications.md`. If any do not, stop and list the unresolved tasks.
4. Print the full routing plan (one line per task: ID, title, route). Pause for my approval.
5. After approval: create a git worktree on branch `forge/NNN-slug` at `.worktrees/NNN-slug/`. Enter the worktree. All remaining edits happen inside it.
6. Execute tasks in ID order using the routing table:
   - `production-code`, tested package → `/forge.tdd` with task title + acceptance criteria
   - `production-code`, tested package + documented module → `/forge.tdd` then `/forge.docs-sync`
   - `production-code`, untested, documented → `implementer` subagent + `code-reviewer` + `/forge.docs-sync`
   - `production-code`, untested, not documented → `implementer` subagent + `code-reviewer`
   - `docs-only` → `/forge.docs-sync`
   - `config` or `scaffolding` → `implementer` subagent + `code-reviewer`
7. After each task: pause and report `T-NNN complete. Proceed to next task? (yes / skip / stop)`
8. After all tasks complete: run `code-reviewer` against the full cumulative diff in the worktree.
9. Exit the worktree. Report:
   `Branch forge/NNN-slug is ready at .worktrees/NNN-slug/. Review, push, or open a PR when satisfied.`
   `Note: .worktrees/ is gitignored. Commit .forge/NNN-slug/ artifacts separately if desired.`

Do not skip step 4. Do not skip the per-task pause in step 7. Do not skip the final review in step 8.
If the pre-edit-guard hook fires on a task routed to implementer-direct, the task is misclassified — re-tag it `production-code` and re-route to `/forge.tdd`.
