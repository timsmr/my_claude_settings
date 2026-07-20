---
name: tdd-workflow
description: TDD workflow for implementing a NEW feature, service, or module — design the skeleton first, then build in vertical slices, one seam and one red test at a time. Use when starting non-trivial new functionality. Do NOT use for bug fixes or small edits (those follow change-discipline rules).
---

# TDD Workflow

Design the whole public surface first, then build it one vertical slice at a time.
Implementation code never precedes its failing test.

## Phase 1 — Design & Structure

1. **Describe the goal** in a short summary: what the feature/service does, which
   domain entities are involved.
2. **Define the project structure**: create the necessary directories and empty
   `__init__.py` / `index.ts` files so the skeleton is visible
   (Python services: use the `scaffold-python-service` skill).
3. **Define domain entities** (`dataclass` / `interface`): fields, value objects,
   enums. No logic yet — only data shapes. If the service has no real domain logic,
   skip domain entities and define application-layer DTOs only.
4. **Define ports** for every infrastructure dependency (repositories, gateways,
   clients) as `Protocol` contracts with full type signatures. No implementations.
5. **Define DTOs and use-case signatures**: use-case classes with full type
   signatures and docstrings, method bodies `raise NotImplementedError` /
   `throw new Error("not implemented")`.

After Phase 1 the entire public surface is readable and reviewable without a single
line of real logic.

6. **Agree the seams under test.** List the seams you will test at and confirm them
   with the user. No test is written at an unconfirmed seam — agreeing them up front
   lands the effort on critical paths instead of every edge case. Fewer seams is
   better: prefer an existing seam, and propose a new one at the highest point you can.

## Phase 2 — Build in vertical slices

Work one slice at a time: **one seam → one failing test → the minimum code that passes
it → repeat**. Each test is a tracer bullet that responds to what the last slice taught
you. Do not write all the tests first: bulk tests written ahead of any implementation
verify imagined behaviour and lock in a test structure chosen before you understood the
problem.

Per slice:
7. **Write one test** at the agreed seam — use-case tests (real domain logic, mocked
   infrastructure ports) in `tests/integration/`; pure domain logic in `tests/unit/`;
   adapter tests against real infrastructure in `tests/integration/` with
   `@pytest.mark.integration`.
8. **Run it and watch it go red** for the right reason — an assertion, not an import
   error or typo.
9. **Write the minimum implementation that turns it green.** Nothing speculative, no
   anticipating the next slice.
10. **Re-run the slice's test plus the suite** for the module you touched.

Order slices so each one is demoable: domain logic before the use-case that
orchestrates it, ports before the adapters that implement them. Never write adapter
code before its port exists.

## Phase 3 — Verify & Refine

11. **Run the entire test suite** — everything green.
12. **Lint & format**: `ruff check --fix` + `ruff format` on the files you touched
    (Python) / `eslint --fix && prettier --write` (TS).
13. **Review**: naming, no dead code left by this change, no layer violations
    (domain must not import infra). Delete unit tests that a new interface-level test
    now supersedes — a test that must change when the implementation changes was
    testing past the interface.

## Key Principles

- **Tests document behavior**: if a test doesn't exist for a behavior, that behavior
  is undefined.
- **Expected values come from an independent source** — a known-good literal, a worked
  example, the spec. An assertion that recomputes the expected value the way the code
  does passes by construction and can never disagree with the code.
- **Refactoring belongs to review, not the loop**: get it green first, then use
  `/simplify` or `/code-review`.
- **Slice boundaries are commit boundaries**: offer a commit when a slice lands green —
  do not commit unprompted.
