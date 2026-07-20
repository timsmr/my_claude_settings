---
name: diagnosing-bugs
description: Disciplined diagnosis loop for hard bugs, flaky failures, and performance regressions — build a red feedback loop first, then minimise, hypothesise, instrument, fix, and lock it down with a regression test. Use when a bug resists the obvious fix, reproduces intermittently, or lives across process/service boundaries.
---

# Diagnosing Bugs

Adapted from mattpocock/skills (MIT). Skip phases only with explicit justification.

## Phase 1 — Build a feedback loop

**This is the skill. Everything else is mechanical.** With a tight pass/fail signal
that goes *red* on this bug, bisection and hypothesis-testing just consume it. Without
one, no amount of reading code will find the cause. Spend disproportionate effort here.
Be aggressive, be creative, refuse to give up.

Ways to build one, cheapest and tightest first:

1. **Failing test** at whatever seam reaches the bug — unit, use-case, or e2e.
2. **HTTP call** against a locally running service (`curl`, `httpx`).
3. **CLI invocation** with a fixture input, diffing output against a known-good snapshot.
4. **Replay a captured payload.** Save the real AMQP envelope, S3 object, or LLM
   response to disk and push it through the code path in isolation.
5. **Throwaway harness.** One worker or module with its ports stubbed, exercising the
   bug path in a single function call.
6. **Property or fuzz loop.** For "sometimes wrong output", run hundreds of generated
   inputs and watch for the failure mode.
7. **Bisection harness.** For a bug that appeared between two known states (commit,
   dataset, model version), automate "set state, check, repeat" for `git bisect run`.
8. **Differential loop.** Same input through two versions or two configs, diff the
   outputs.
9. **Human-in-the-loop script.** Last resort, for flows that need a person to act —
   drive them with a script that prints steps and reads their answers back.

**Tighten the loop — treat it as a product.** Faster (cache setup, skip unrelated
init), sharper (assert the specific symptom, not "didn't crash"), more deterministic
(pin time, seed RNG, isolate the filesystem, freeze the network). A 30-second flaky
loop is barely better than nothing; a 2-second deterministic one is a superpower.

**Intermittent bugs**: the goal is a *higher reproduction rate*, not a clean repro.
Loop it hundreds of times, run it in parallel, add load, narrow the timing window,
inject sleeps at suspected race points. 50% is debuggable; 1% is not — keep raising it.

**If no loop can be built**, stop and say so. List what you tried and ask for
environment access, a captured artifact (payload dump, log export, trace), or
permission to instrument the live system temporarily. Do not proceed to hypotheses
without a loop.

**Gate.** Phase 1 is done when you can name **one command you have already run**, with
its invocation and output pasted, that is *red-capable* (drives the real path and
asserts the user's exact symptom — not merely "runs without erroring"), *deterministic*,
*fast*, and *agent-runnable*. Reading code to build a theory before that command exists
is the exact failure this skill prevents: stop and go build the loop.

## Phase 2 — Reproduce and minimise

Confirm the loop reproduces *the user's* failure mode, not a nearby one — wrong bug,
wrong fix. Then shrink to the smallest scenario that still goes red: cut inputs,
callers, config, data, and steps **one at a time**, re-running after each cut.

**Gate.** Every remaining element is load-bearing — removing any one turns the loop
green. This minimised case becomes the Phase 5 regression test.

## Phase 3 — Hypothesise

Generate **3–5 ranked hypotheses before testing any of them**; a single hypothesis
anchors you to the first plausible story. Each must be falsifiable: "if X is the
cause, then changing Y makes it disappear." A hypothesis with no stated prediction is
a vibe — sharpen it or drop it.

Show the ranked list to the user if they are present — domain knowledge re-ranks it
instantly and cheaply. Proceed with your own ranking if they are away.

## Phase 4 — Instrument

Each probe maps to a specific prediction, and you change **one variable at a time**.
Prefer a debugger or REPL over logs — one breakpoint beats ten log lines. Place logs
only at boundaries that distinguish hypotheses; never log everything and grep.

Tag every temporary log so it can be found and removed: bind a marker field rather
than editing the message, e.g. `logger.bind(dbg="a4f2").info("step_advance", ...)`,
and grep the marker in Phase 6.

For performance regressions, logs are usually the wrong tool: measure a baseline first
(timing harness, profiler, `EXPLAIN` on the query), then bisect the regression.
Measure first, fix second.

## Phase 5 — Fix and lock it down

Write the regression test **before the fix** — but only where a correct seam exists.
A correct seam exercises the real bug pattern as it occurs at the call site; a test
that cannot replicate the triggering chain gives false confidence.

**If no correct seam exists, that is itself the finding.** Report it: the architecture
is preventing the bug from being locked down.

Otherwise: minimised repro → failing test at the seam → watch it fail → apply the fix →
watch it pass → re-run the Phase 1 loop against the **original, un-minimised** scenario.

## Phase 6 — Clean up

Done when: the original repro no longer reproduces; the regression test passes (or the
missing seam is documented); every tagged debug log is removed (grep the marker);
throwaway harnesses are deleted or moved to a clearly marked scratch location; and the
hypothesis that proved correct is stated in the commit message, so the next debugger
learns from it.

Then ask what would have prevented this bug. Make that recommendation **after** the fix
is in — you know more now than when you started.
