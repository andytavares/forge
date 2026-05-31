# Tasks: 004 — forge.research Skill

## Problem Statement

The harness has no command for open-ended feasibility research. `/forge.plan` assumes an in-progress feature; `/forge.ask` answers one-off questions; neither produces a durable, options-comparison document. This feature adds a `/forge.research` slash command backed by a new `research-topic` skill, updates the version constant to 0.3.0, appends two entries to `doc-index.json`, and updates both `README.md` and `forge-blog.md` to reflect the new counts and entries.

---

## Task List

| ID | Title | Type | Depends on | Acceptance criteria |
|---|---|---|---|---|
| T-01 | Create research-topic skill body | `skill` | — | A file exists at `.claude/skills/research-topic/SKILL.md` with valid YAML frontmatter, a 5-phase workflow section, and a `See canonical-research` delegation line; the file is under 500 lines. |
| T-02 | Create research-doc-schema reference file | `docs-only` | T-01 | A file exists at `.claude/skills/research-topic/references/research-doc-schema.md` containing all 9 required schema sections (Header through Next Steps) as a numbered list with field descriptions. |
| T-03 | Create forge.research command file | `command` | T-01, T-02 | A file exists at `.claude/commands/forge.research.md` with frontmatter `description`, a step-by-step flow that delegates to the `researcher` subagent with the `research-topic` skill, and an `AskUserQuestion` menu with exactly 4 labeled choices (Accept, Regenerate, Extend with more sources, Abort). |
| T-04 | Bump installer VERSION to 0.3.0 | `script` | — | Line 13 of `scripts/forge.sh` reads `VERSION="0.3.0"`; running `./scripts/forge.sh --help` outputs `0.3.0`. |
| T-05 | Append doc-index entries for new files | `config` | T-01, T-03 | `.claude/doc-index.json` contains two new entries: one for `.claude/commands/forge.research.md` with `referenced_code_paths` including the skill path, and one for `.claude/skills/research-topic/SKILL.md` with `referenced_code_paths` including the schema reference path; both have a non-null `title` and `summary`. |
| T-06 | Update README skill and command counts | `docs-only` | T-01, T-03 | `README.md` reads "Fourteen skills" and "Fifteen slash commands", with `research-topic` in the skills list and `/forge.research` in the commands list. |
| T-07 | Update forge-blog skill list and commands table | `docs-only` | T-01, T-03 | `forge-blog.md` skill-count phrase reads "fourteen", commands count reads "Fifteen commands", `research-topic` bullet is present, and a `/forge.research` row is present in the commands table. |

---

## Routing Notes

- **TDD workflow:** Not applicable — no automated tests exist for skill or command files in this harness.
- **Docs-only tasks:** T-02, T-06, T-07 are pure documentation. T-05 is config-only.
- **T-04** (version bump) is technically independent but should be done last as a release-hygiene convention.
- **T-05** requires T-01 and T-03 to exist before writing `referenced_code_paths` — do not write doc-index entries speculatively.
- **T-06 and T-07** are independent of each other; can run in parallel after T-01 and T-03.
- The `last_verified_commit` field in T-05 should be set to the commit that lands T-01 and T-03, not the current HEAD.
