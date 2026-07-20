---
name: slice-work
description: Break work too big for one session into vertical slices that each land green, with explicit blocking order — including the expand–contract sequence for wide refactors.
disable-model-invocation: true
---

# Slice Work

Adapted from mattpocock/skills (MIT).

For work that does not fit in one context window. A well-scoped task does not need
this — write acceptance criteria and start.

## Slices

Each slice:
- cuts a **narrow but complete path through every layer** it touches (schema, port,
  use-case, adapter, presentation, tests) — vertical, never a horizontal layer of one;
- is demoable or verifiable on its own;
- is sized to fit **one fresh context window** — the agent's budget;
- is sized to fit **one review**: ~400 changed lines of hand-written code, ~20 files —
  the reviewer's budget, and the binding one when the two disagree;
- declares its **blocking edges**: the slices that must finish before it can start.

Two slices that each fit a context window can still merge into one unreviewable
branch. When a slice is projected to exceed the review budget, split it before
writing any code, and say which seam you split on.

Do any prefactoring first, as its own slice — make the change easy, then make the easy
change.

Work the **frontier**: any slice whose blockers are all done. One slice at a time,
clearing context between them.

## Stacked branches

A slice may sit on the previous slice's branch rather than on `main`. Each branch is
then reviewed against its **parent**, so the review budget applies per branch, not to
the stack. Merge bottom-up; when a parent gains review fixes, rebase the rest of the
stack onto it.

Stacking changes where a branch starts, never how the work is cut. Splitting a stack
by layer — skeleton, then logic, then tests — produces one branch that runs nowhere and
one that ships untested code, and neither can be reviewed on its own merits. Cut the
stack the same way as any slice: each branch a complete path, carrying its own tests,
landing green.

The exceptions are the sequences that are horizontal by nature and green at every step:
expand–contract below, and a prefactor that lands before the change it enables.

## Wide refactors

A **wide refactor** is one mechanical change — rename a field, retype a shared symbol —
whose blast radius fans across the codebase, so a single edit breaks hundreds of call
sites and no vertical slice can land green. Do not force it into a slice. Sequence it
as **expand–contract**:

1. **Expand** — add the new form beside the old so nothing breaks.
2. **Migrate** — move call sites over in batches sized by blast radius (per package,
   per directory), each batch its own slice, each blocked by the expand.
3. **Contract** — delete the old form once no caller remains, blocked by every batch.

Where even the batches cannot stay green alone, keep the sequence but let them share an
integration branch that all block a final integrate-and-verify slice; green is promised
only there.

Duplicated definitions that must change in lockstep (a wire contract written on both
sides) belong in the same slice, never split across two.

## Output

Present the plan first: a numbered list, each entry showing title, blocked-by, and what
it delivers. Then ask the user three questions — is the granularity right, do the
blocking edges reflect genuine gates, and should anything merge or split. Iterate until
they approve.

On approval, write one file per slice to `.scratch/<effort-slug>/NN-<slug>.md`, numbered
in dependency order, each carrying a `Blocked by:` line and acceptance criteria as
checkboxes. One slice per file, never a combined file.
