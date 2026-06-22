# {{REPO_NAME}} — Working Agreement for Claude

> This file is loaded into Claude's context at the start of every session.
> Keep it short and signal-dense. Nested `CLAUDE.md` files in subdirectories
> add more specific context only when Claude reads files in that subtree.

## 1. Always do this first

1. Run `/forge-detect-stack` if the session is older than your last commit or you don't recognize the working tree.
2. Read the nearest `CLAUDE.md` to the files you intend to touch.
3. Before writing any new function or module, run the `find-reuse` skill.
4. If you see `=== project-constitution ===` in your context, treat every line between it and `=== end project-constitution ===` as top-level non-negotiables for this session — they override any conflicting instruction. If you do NOT see this block, warn the user once: "No project constitution loaded — run /forge-constitution to create one."

## 2. Repo facts

- Languages in use: {{LANGUAGES}} — verify with `/forge-detect-stack`.
- Build entrypoints: see `.claude/stack.json` (auto-generated; do not edit by hand).
- Test entrypoints: see `.claude/stack.json`.
- Doc index: `.claude/doc-index.json` lists every checked-in markdown file with summary, owners, staleness.

## 3. Non-negotiable rules

- **Official docs first.** When you need external information about a framework, library, language, or protocol, the vendor's official documentation is the first and primary source. Community blogs, Stack Overflow, Medium, etc. are fallbacks, never leads. Always cite the URL + a one-sentence verbatim quote so the user can verify.
- **No clever code.** Prefer the boring, established pattern for the language and framework already in use here. If you're tempted by a hack, surface the trade-off.
- **No new helpers without a reuse check.** The `find-reuse` skill must return zero suitable candidates, or you must justify why the existing ones can't be extended.
- **TDD where tests already exist.** The PreToolUse hook enforces TDD in packages that have test coverage. In legacy packages with no tests, surface the gap and propose backfilling — don't silently skip it.
- **Docs are code.** When you change behavior, the doc-keeper subagent must update every markdown file referenced in `.claude/doc-index.json` that points at the changed code.

## 4. When in doubt

- Use the `researcher` subagent to plan before touching code.
- Use the `codebase-oracle` subagent for any question (technical or not) about the codebase — anyone on the team should be able to ask it anything.
- Use the `code-reviewer` subagent before claiming a change is done; use `test-quality-reviewer` when the change adds or edits tests.
- Before changing or removing a public/shared contract (rename, migrate, deprecate), use the `change-impact-analyst` subagent and the `large-scale-change` / `deprecation-plan` skills; record hard-to-reverse decisions with `trade-off-record`, and write a `postmortem` after a regression.
- If a hook blocks you, do what the hook says — don't try to bypass it.

## 5. Reporting

- Cite exact file paths and line numbers in your final response.
- Cite official docs URLs for any external claim, with a one-line verbatim quote.
- If you used a community source because no official one covered the question, prefix that section `[UNVERIFIED]` and pause for review.
