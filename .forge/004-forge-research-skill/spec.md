# Spec: /forge-research Skill

## Problem Statement

The harness has no command for open-ended feasibility research. `/forge-plan` assumes you have a feature to plan. `/forge-ask` answers one-off questions. Neither produces a durable, options-comparison document grounded in official sources. `forge.research` fills that gap.

## New Files

| File | Purpose |
|---|---|
| `.claude/commands/forge-research.md` | The slash command the user invokes |
| `.claude/skills/research-topic/SKILL.md` | The 5-phase workflow for the researcher subagent |
| `.claude/skills/research-topic/references/research-doc-schema.md` | The output document schema |

## How It Works (Step-by-Step Flow)

```
/forge-research <topic>
  │
  ├─ 1. Counter-scan .forge/ → determine NNN; create .forge/NNN-slug/
  ├─ 2. Write topic.md (verbatim input)
  ├─ 3. Delegate to researcher subagent with research-topic skill
  │      Phase 1 — Parse topic; identify domain; flag ambiguities
  │      Phase 2 — Grep/Read codebase; call find-reuse; collect file:line evidence
  │      Phase 3 — Enumerate 2–4 options; WebFetch official docs (canonical-research rules)
  │      Phase 4 — Analyze each: feasibility, complexity, risks, codebase fit
  │      Phase 5 — Assemble research.md using 9-section schema
  ├─ 4. Write output to .forge/NNN-slug/research.md
  └─ 5. AskUserQuestion menu:
         • Accept → report path + suggest /forge-tasks NNN
         • Regenerate → overwrite research.md, re-run
         • Extend with more sources → additional topics/domains, re-run Phase 3–5
         • Abort → exit; folder kept
```

The `research-topic` skill composes `canonical-research` (references it, does not re-state the rules). The `researcher` subagent is the executor — no new subagent needed.

## Output Document Schema (research.md)

Every research document always contains:

1. Header (date, topic, codebase context paragraph)
2. Problem Statement
3. Scope (in / out)
4. Codebase Context (file:line citations)
5. Options Considered (per-option: official source URL + verbatim quote, feasibility, complexity, risks, codebase fit)
6. Comparison Table
7. Recommendation (one option, named, with trade-off)
8. Open Questions (optional)
9. Next Steps (optional)

## Installer Script Changes

**`scripts/forge.sh`** — `forge_source_files()` auto-discovers by scanning `.claude/skills/` and `.claude/commands/` directory trees. No manual registration needed. Placing the new files in the right directories is sufficient for install/update/uninstall/status to handle them automatically.

**One change required:** Bump `VERSION="0.2.0"` → `"0.3.0"` to mark the release.

## Documentation Updates

| File | Required Change |
|---|---|
| `README.md` | "Thirteen skills" → "Fourteen"; "Fourteen slash commands" → "Fifteen"; add `research-topic` and `/forge-research` to their respective lists |
| `forge-blog.md` | "thirteen" → "fourteen" (skill count); "Fourteen commands" → "Fifteen"; add `research-topic` bullet; add `/forge-research` row to commands table |
| `.claude/doc-index.json` | Append two new entries (for the command and the skill) so `post-edit-doc-mark.sh` can track staleness |

## Risks

- **Overlap with `canonical-research`:** The skill body must delegate by reference, not copy the sourcing rules.
- **Overlap with `forge.plan`:** The command description must use investigation-intent verbs ("research", "investigate", "survey") to avoid triggering on feature requests.
- **Counter-scan race:** The NNN counter must be re-scanned at folder-creation time, not at command startup.
- **WebFetch domain prompts:** First run on a new domain will prompt the user for permission — expected behavior, worth noting in the skill body.

## Acceptance Criteria

1. `/forge-research <topic>` creates `.forge/NNN-slug/research.md` with all 9 sections present.
2. Every external claim has a `Source: <Title> — <URL>` + `Quote: "<verbatim>"` line from first-party docs.
3. Every codebase claim has a `file:line` citation.
4. Recommendation names exactly one option and references at least one codebase finding.
5. AskUserQuestion menu with exactly 4 choices appears before the command exits.
6. After `forge.sh install/update/uninstall`, both new files behave like all other forge-managed files.
7. README and blog counts are correct after docs update.
