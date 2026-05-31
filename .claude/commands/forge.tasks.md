---
description: Decompose a spec into a numbered feature folder and structured task list in .forge/NNN-slug/
---

Create a task list for: $ARGUMENTS

1. Scan `.forge/` for existing `NNN-*` directories to determine the next counter (001, 002, …). Slugify the first 4–5 words of the spec to form the folder name. Create `.forge/NNN-slug/`.
2. Write the verbatim spec text to `.forge/NNN-slug/spec.md`. If `$ARGUMENTS` is a file path, read that file's contents and write them.
3. Run the `researcher` subagent to read the spec and any files it references.
4. Run the `task-decomposition` skill to generate the structured task list.
5. Print the full task list for review.
6. Pause for my approval.
7. After approval: write the task list to `.forge/NNN-slug/tasks.md`.
8. Report: `Feature NNN created at .forge/NNN-slug/. Run /forge.clarify NNN to resolve ambiguities, or /forge.implement NNN to begin.`

Do not write tasks.md before step 7. Do not skip the pause in step 6.
