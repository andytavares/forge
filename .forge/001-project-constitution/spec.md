Implement /forge-constitution — a skill that generates and manages .forge/constitution.md via interactive LLM-assisted authoring. The constitution is a "soul file" encoding project purpose, non-negotiables, architectural principles, risk posture, team conventions, and out-of-scope items. It must be injected into Claude's context at every SessionStart and after every PostCompact event.

Files to create/modify:
1. CREATE .claude/commands/forge-constitution.md — slash command definition
2. CREATE .claude/skills/project-constitution/SKILL.md — the authoring skill
3. MODIFY .claude/hooks/session-start.sh — inject constitution block at the end
4. CREATE .claude/hooks/post-compact.sh — new hook: reinject constitution after context compaction
5. MODIFY .claude/settings.json — wire PostCompact hook
6. MODIFY CLAUDE.md — add constitution sentinel to "Always do this first" section
7. MODIFY scripts/forge.sh — add .forge/constitution.md to list_user_owned_paths(); add post-compact.sh to managed paths
8. MODIFY .claude/doc-index.json — add entries for forge.constitution.md and .forge/constitution.md

Constitution schema (required H2 sections in .forge/constitution.md):
- ## Purpose
- ## Non-negotiables
- ## Architectural principles
- ## Risk posture
- ## Team conventions
- ## Out of scope
