---
name: grill
description: Interview the user about a plan, design, or change until every decision is resolved — then capture the resulting vocabulary and hard-to-reverse decisions.
disable-model-invocation: true
---

# Grill

Adapted from mattpocock/skills (MIT).

Interview the user until the design tree has no unresolved branches, then write down
what the session decided.

## The interview

Walk the decision tree, resolving dependencies between decisions one by one.

**Facts are yours to find; decisions are the user's.** Anything derivable from the
repo, filesystem, git history, or tools — look it up. Dispatch subagents for lookups
that would otherwise block a question. Put only genuine decisions to the user.

**One question at a time**, waiting for the answer before the next. Several at once
is bewildering. (If the user asks for `batch` mode: ask the whole *frontier* instead —
every question whose prerequisites are already settled — as one numbered round, then
recompute the frontier from the answers. A question that depends on another still open
in this round belongs to a later round.)

**Every question carries your recommended answer**, so the user reviews a proposal
instead of composing one from scratch.

Sharpen as you go:
- **Challenge fuzzy terms.** "You're saying 'account' — the Customer or the User?
  Those are different things."
- **Invent edge-case scenarios** that force precision about boundaries between concepts.
- **Cross-reference the code.** When a claim contradicts the source, say so: "Your code
  cancels whole Orders, but you said partial cancellation is possible — which is right?"

The session ends when no branch is left silently assumed. Confirm shared understanding
with the user before acting on any of it.

## Capture

Write these down as they crystallise, not in a batch at the end.

**Vocabulary** → a `## Glossary` section in the project's `CLAUDE.md`. One entry per
term: the term, a one-or-two-sentence definition of what it *is*, and an `_Avoid_:`
list of the synonyms it replaces. Be opinionated — when several words exist for one
concept, pick one and retire the rest. Only terms specific to this project: general
programming concepts (timeout, retry, DLX) stay out however often they appear.

**Decisions** → `docs/adr/NNNN-slug.md`, numbered one above the highest existing file.
One to three sentences: the context, the decision, and why. A single paragraph is a
complete ADR.

Record an ADR only when all three hold:
1. the decision is hard to reverse,
2. it would surprise someone without the context,
3. it came from a real trade-off, not the only available option.

Miss any one and skip it — an easy reversal gets reversed, an unsurprising choice
raises no questions, and a forced move has nothing to record.

Deliberate deviations from the obvious path are the highest-value category: they stop
the next engineer from "fixing" something that was intentional. Rejected alternatives
qualify when the rejection is non-obvious.
