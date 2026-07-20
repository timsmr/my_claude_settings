---
name: writing-great-skills
description: Reference for writing and editing skills and rules well — the vocabulary, levers, and failure modes that make instructions predictable.
disable-model-invocation: true
---

# Writing Great Skills

Adapted from mattpocock/skills (MIT). All reference, no steps. Applies to rule files
as much as to skills.

A skill exists to wrangle determinism out of a stochastic system. **Predictability** —
the agent taking the same *process* every run, not producing the same output — is the
root virtue; every lever below serves it. Token cost and maintainability are symptoms
of it, not rivals.

## Invocation — two states, two costs

| | Model-invoked | User-invoked |
|---|---|---|
| Mechanics | keep `description` | `disable-model-invocation: true` (+ `policy.allow_implicit_invocation: false` for Codex) |
| Reachable by | model, user, and other skills | the human only |
| `description` is | model-facing, rich triggers | human-facing one-liner, triggers stripped |
| Costs | **context load** — tokens and attention, every turn | **cognitive load** — the human is the index |

There is no model-only state: a description only ever *adds* agent discovery. Choose
model-invocation when the agent (or another skill) must reach it on its own; anything
that only ever fires by hand should be user-invoked and pay no context load.

Cognitive load is not a cost to minimise — it is the price of human agency. Spend it
where judgment matters, remove it where it does not. When it piles up, the cure is a
**router**: one user-invoked skill that names the others. It can only hint, never fire
them.

Description rules: front-load the leading word; one trigger per branch (synonyms
renaming a single branch are duplication); cut identity that already lives in the body.

## Information hierarchy

One ladder, ranked by how immediately the agent needs the material:

1. **Step** — an ordered action in `SKILL.md`. The primary tier.
2. **In-file reference** — consulted on demand, in the same file.
3. **Disclosed reference** — a sibling or external file behind a pointer.

The disclosure test is branching: inline what *every* branch needs, push behind a
pointer what only *some* branches reach. Push too little down and the top bloats; push
too much and you hide material the agent needs. In-file reference that should have been
disclosed buries the steps and turns attending to them into a coin flip.

A **pointer's wording**, not its target, decides how reliably the agent reaches the
material. A must-have target behind a weakly worded pointer is a variance bug: sharpen
the wording first, inline the material only if that fails.

Each step ends on a **completion criterion** with two independent axes: *clarity*
(can the agent tell done from not-done?) resists premature completion, and *demand*
("every modified model accounted for", not "produce a change list") sets how much
legwork the agent does. The strongest criteria are both checkable and exhaustive.

## When to split

Each cut spends one of the two loads, so split only when the cut earns it.

- **By invocation** — when a distinct leading word should trigger it, or another skill
  must reach it. You pay permanent context load for the new description.
- **By sequence** — when the steps still ahead tempt the agent to rush the one in front
  of it. This only works across a real context boundary (a user-invoked hand-off or a
  subagent dispatch); an inline call leaves the later steps in context and clears
  nothing.

## Leading words

A **leading word** is a compact concept already living in the model's pretraining that
the agent thinks with while running the skill — *red*, *tight*, *seam*, *fog of war*,
*tracer bullet*. Repeated as a token (never as a restated sentence), it accumulates a
distributed definition and anchors a whole region of behaviour in very few tokens.

It pays twice: in the body it anchors execution, and in the description it anchors
invocation — when the same word lives in your prompts, docs, and code, the skill fires
more reliably.

Worked conversions: "fast, deterministic, low-overhead" → a *tight* loop; "a loop you
believe in" → the loop goes *red*, converting a fuzzy gate into a binary observable
state. Coining your own word works if you define it, but it recruits no priors — you
pay in definition tokens what a pretrained word gives free. Assume every skill is
carrying restatements that leading words retire.

## Failure modes

- **Premature completion** — ending a step before it is genuinely done, attention
  slipping toward *being done*. A tug-of-war between visible later steps (the pull) and
  the completion criterion's clarity (the resistance). Fuzziness is the necessary
  condition. Fix in order: sharpen the criterion first (cheap, local); only if it is
  irreducibly fuzzy *and* you observe the rush, split to hide what follows.
- **Duplication** — one meaning in more than one place. Costs maintenance and tokens,
  and inflates that meaning's prominence past its real rank. The accidental inverse of
  a leading word, which repeats a token on purpose, never the meaning.
- **Sediment** — stale layers that settle because adding feels safe and removing feels
  risky. The default fate of anything without a pruning discipline.
- **Sprawl** — simply too long, even when every line is live and unique.
- **No-op** — a line the model already obeys by default, so you pay load to say
  nothing. The test: does it change behaviour versus the default? This is
  model-relative — two people disagreeing about whether a line is a no-op disagree
  about the default, and settle it by running the skill, not by debating.
- **Negation** — steering by prohibition backfires: *don't think of an elephant* names
  the elephant and makes it more available. Prompt the positive. Keep a prohibition
  only as a hard guardrail you cannot phrase positively, and pair it with what to do
  instead.

## Pruning

Three passes. **Single source of truth**: each meaning in one authoritative place, so
changing behaviour is a one-place edit. **Relevance**: does the line still bear on what
this does? **No-ops**: hunt them sentence by sentence, not line by line — when a
sentence fails the test, delete the whole sentence rather than trimming words. Be
aggressive; most prose that fails should go, not be rewritten.
