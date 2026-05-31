---
description: Identify and interactively resolve ambiguities in a feature's spec and task list, writing .forge/NNN-slug/clarifications.md
---

Clarify feature: $ARGUMENTS

If $ARGUMENTS is empty, use the highest-numbered folder in `.forge/`.
If $ARGUMENTS is a number (e.g. `001`), resolve it to the matching `.forge/NNN-*` folder.

1. Read `.forge/NNN-slug/tasks.md`. If it does not exist, stop: "Run /forge.tasks first."
2. Read `.forge/NNN-slug/spec.md` for original context.
3. Run the `clarify-spec` skill to identify all ambiguities.
4. If no ambiguities are found, write `.forge/NNN-slug/clarifications.md` with zero entries and report: "No ambiguities found. Ready to implement."
5. Otherwise, present ambiguities one at a time:
   - Show the ambiguity title, the quoted spec/task phrase that is unclear, and 2–4 options with a [RECOMMENDED] option marked.
   - Wait for my response before presenting the next question.
   - If I type `skip` or `defer`, record resolution as DEFERRED and move on.
6. After all ambiguities are answered: write `.forge/NNN-slug/clarifications.md`.
7. Report: `N resolved, N deferred. Run /forge.implement NNN to begin.`

Do not batch multiple questions into a single message. One question at a time.
