---
name: rules-review
description: Audit and improve the user's global rules and skills (~/.claude/rules, ~/.claude/skills) using accumulated feedback — scans per-project memory for generalizable lessons, diagnoses each file against the failure modes in writing-great-skills, proposes concrete edits, applies only after explicit approval. Use when the user asks to review, update, or improve their rules or skills, or when generalizable feedback has accumulated during a session.
---

# Rules Review

Goal: keep the always-loaded rules and the installed skills small, consistent, and
honest — every line must change model behavior; everything else gets deleted or moved
down a tier.

Read the `writing-great-skills` skill first: its failure modes and vocabulary are the
diagnostic set this review runs on.

## Procedure

1. **Gather evidence.** Scan per-project memory dirs
   (`~/.claude/projects/*/memory/`) for entries with `metadata.type: feedback`,
   plus user corrections from the current conversation. Keep only lessons that
   generalize beyond one project (project-specific ones belong in that project's
   CLAUDE.md or memory).
2. **Audit the rules.** Read every file in `~/.claude/rules` and diagnose against the
   six failure modes: **no-op** (obeyed by default anyway — including anything
   ruff/eslint/mypy already enforces), **duplication**, **sediment** (stale, no longer
   true), **sprawl**, **negation** (a prohibition that could be phrased positively),
   **premature completion**. Also check tiering: is this always-on, `paths:`-scoped,
   or does it belong in an on-demand skill?
3. **Audit the skills.** Read the frontmatter of every skill in `~/.claude/skills` and
   the body of any that the evidence or your own judgment flags. Check:
   - **Invocation is deliberate** — model-invoked skills pay permanent context load
     for their description; anything that only ever fires by hand should carry
     `disable-model-invocation: true` (and `policy.allow_implicit_invocation: false`
     in `agents/openai.yaml`).
   - **Descriptions earn their tokens** — one trigger per branch, no identity that
     already lives in the body, leading word front-loaded.
   - **Spec conformance** — `name` matches the directory name, description ≤1024
     chars, `SKILL.md` under ~500 lines.
   - **Overlap** — two skills whose triggers collide will fire unpredictably; say
     which should absorb the other.
   - **Contradiction** — a skill instructing something the rules forbid, or two skills
     prescribing opposite methods.
   Skills bundled by Anthropic or installed from a marketplace are out of scope —
   audit only the user's own.
4. **Draft changes.** For each proposed change: file, exact edit, one-line rationale,
   evidence source. New rules state one fact each, target non-default behavior, and
   carry an example only if genuinely ambiguous without one.
5. **Get approval.** Present the proposal compactly (AskUserQuestion for real forks,
   plain summary otherwise). NEVER edit rules or skills without explicit approval.
6. **Apply.** First back up: `cp -R ~/.claude/rules ~/.claude/backups/rules-<date>/`.
   Apply approved edits; report per-file byte sizes before/after.
7. **Close the loop.** If a feedback memory is now encoded in a rule, update the
   memory to reference the rule instead of deleting it. Then, if the settings repo
   (`~/Desktop/my_claude_settings`) exists: sync the changed files into it, run
   `./install.sh` so the edits reach every harness, and tell the user to commit —
   a rule that only lives in `~/.claude` has not shipped.

## Constraints

- Token budget is the point: always-on set stays ~1-2KB (change-discipline.md);
  path-scoped Python set ≤ 10KB; TS set ≤ 4KB. Refuse additions that break the
  budget without removing something else.
- Respect the tiering: procedures/recipes → skills; linter-expressible → linter
  config; project-specific → that project's CLAUDE.md; portable behavioral rules →
  always-on.
- Keep the user's voice and file layout (one topic per file, STRICT RULE markers).
