# Change Discipline

## Task Contract
Non-trivial task → before coding, restate it as acceptance criteria: what will be
true when done, which edge cases are covered, what is out of scope. Can't state
the criteria → the task is underspecified: ask.

## Surgical Changes
Every changed line must trace directly to the task.
- Leave adjacent code, comments, and formatting exactly as found.
- Refactor only what the task requires. Precedence: when editing existing files, local
  style wins over the style rules; the rules govern new files.
- Spotted unrelated dead code or a bug? Report it in your response and leave it in place.
- Clean up your own orphans: remove imports/variables/functions that YOUR change made
  unused. Pre-existing dead code stays unless asked.

## Assumptions Up Front
Facts are yours to find; decisions are the user's. Anything derivable from the repo,
filesystem, git history, or tools — look it up rather than asking.
Before non-trivial implementation, state key assumptions in 1-2 lines.
- Multiple readings of the task → name the one you picked; don't pick silently.
- A simpler approach exists → say so, push back when warranted.
- Genuinely blocked by a decision only the user can make → ask; otherwise pick a
  sensible default and proceed.

## Branch Size
Before starting a new unit of work on an existing branch, check what it already
carries: `git diff --stat <target-branch>...HEAD`. Past ~400 changed lines of
hand-written code or ~20 files — excluding generated files, lockfiles, and mechanical
migrations — land what is there before adding more: say so, and propose where to cut.
Reviewers lose defects in large diffs, so the ceiling belongs to them, not to you.
Work already in progress gets finished; the check gates starting more, never
abandoning what is half-done.
A whole new service, worker, or module lands as one branch when splitting it would
ship something that runs nowhere — name that reason explicitly rather than letting
the ceiling pass unmentioned.

## Definition of Done
Done = demonstrated, not assumed: tests green + lint clean + the affected path
actually exercised (run the service/endpoint/script). Report what you ran and saw,
not what should work.

## Bug Fixes Are Test-First
Reproduce the bug with a failing test before fixing; the fix makes it pass.
Refactors: full suite green before and after.
Escape hatch: untestable or trivial fixes (typo, config value) — fix directly and
say why there is no test.
A bug that resists the obvious fix, reproduces intermittently, or spans process
boundaries → follow the `diagnosing-bugs` skill.

## New Features
Implementing a new feature, service, or module → follow the `tdd-workflow` skill.
Work too large for one session → slice it first with the `slice-work` skill.

## Guardrails
- New third-party dependency → name it and justify it before adding; prefer stdlib
  or already-installed deps.
- Keep secrets and tokens in env/config only, and mask them in log output. Never
  hardcode them in code, tests, or logs.
- If your change invalidates the project's CLAUDE.md, update it in the same change.
- When a behavioral plugin (e.g. ponytail) conflicts with these rules or a skill,
  the rules/skill win.

## Improving These Rules
When user feedback generalizes beyond the current task, propose a rule update
(the `rules-review` skill audits the whole set). Edit `~/.claude/rules` only with
explicit user approval.
