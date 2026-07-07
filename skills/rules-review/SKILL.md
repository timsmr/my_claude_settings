---
name: rules-review
description: Audit and improve the user's global Claude Code rules (~/.claude/rules) using accumulated feedback — scans per-project memory for generalizable lessons, checks rules for contradictions/staleness/linter-redundancy, proposes concrete edits, applies only after explicit approval. Use when the user asks to review, update, or improve their rules, or when generalizable feedback has accumulated during a session.
---

# Rules Review

Goal: keep `~/.claude/rules` small, consistent, and honest — every line must change
model behavior; everything else gets deleted or moved down a tier.

## Procedure

1. **Gather evidence.** Scan per-project memory dirs
   (`~/.claude/projects/*/memory/`) for entries with `metadata.type: feedback`,
   plus user corrections from the current conversation. Keep only lessons that
   generalize beyond one project (project-specific ones belong in that project's
   CLAUDE.md or memory).
2. **Audit the current set.** Read every file in `~/.claude/rules`. For each rule ask:
   still true? contradicted by a sibling file or by a code example? duplicated?
   expressible in linter config instead (ruff/eslint/mypy → delete the prose and,
   if needed, propose the linter change)? in the right tier (always-on vs
   `paths:`-scoped vs on-demand skill)?
3. **Draft changes.** For each proposed change: file, exact edit, one-line rationale,
   evidence source. New rules must state one fact each, target non-default behavior,
   and carry an example only if genuinely ambiguous without one.
4. **Get approval.** Present the proposal compactly (AskUserQuestion for real forks,
   plain summary otherwise). NEVER edit the rules without explicit approval.
5. **Apply.** First back up: `cp -R ~/.claude/rules ~/.claude/backups/rules-<date>/`.
   Apply approved edits; report per-file byte sizes before/after.
6. **Close the loop.** If a feedback memory is now encoded in a rule, update the
   memory to reference the rule instead of deleting it.

## Constraints

- Token budget is the point: always-on set stays ~1-2KB (change-discipline.md);
  path-scoped Python set ≤ 10KB; TS set ≤ 4KB. Refuse additions that break the
  budget without removing something else.
- Respect the tiering: procedures/recipes → skills; linter-expressible → linter
  config; project-specific → that project's CLAUDE.md; portable behavioral rules →
  always-on.
- Keep the user's voice and file layout (one topic per file, STRICT RULE markers).
