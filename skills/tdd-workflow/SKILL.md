---
name: tdd-workflow
description: Phase-ordered TDD workflow for implementing a NEW feature, service, or module — design skeleton first, red tests second, implementation third, verification last. Use when starting non-trivial new functionality. Do NOT use for bug fixes or small edits (those follow change-discipline rules).
---

# TDD Workflow

Follow this strict order. Do NOT skip phases or write implementation code before tests.

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

## Phase 2 — Tests (red)

6. **Write use-case tests** in `tests/integration/` — real domain logic, mocked
   infrastructure ports (see python-testing.md). Tests must compile and **fail**.
7. **Write unit tests** for pure domain logic in `tests/unit/`, and adapter tests
   against real infrastructure (testcontainers, `@pytest.mark.integration`).
   These also fail at this point.
8. **Run the full test suite** to confirm everything fails for the right reasons
   (assertions, not import errors or typos).

## Phase 3 — Implementation

9. **Implement domain logic**: entity methods, validation, domain services.
   Re-run unit tests — they start passing.
10. **Implement use-cases**: orchestrate domain logic, call ports.
    Re-run use-case tests in `tests/integration/` — they should pass.
11. **Implement infrastructure adapters**. Re-run adapter tests — they should pass.
12. **Implement presentation layer** and wire everything in the composition root.

## Phase 4 — Verify & Refine

13. **Run the entire test suite** — everything green.
14. **Lint & format**: `ruff check . --fix && ruff format .` (Python) /
    `eslint --fix && prettier --write` (TS).
15. **Review**: naming, no dead code left by this change, no layer violations
    (domain must not import infra).

## Key Principles

- **No forward jumps**: never write adapter code before its port exists and is tested.
- **Tests document behavior**: if a test doesn't exist for a behavior, that behavior
  is undefined.
- **Fail fast**: run tests after every phase; fix compilation/import errors immediately.
- **Phase boundaries are commit boundaries**: offer a commit at each boundary —
  do not commit unprompted.
