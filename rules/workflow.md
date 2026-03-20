# Development Workflow

When implementing a new feature or service, follow this strict order. Do NOT skip phases or write implementation code before tests.

## Phase 1 — Design & Structure

1. **Describe the goal** in a short summary: what the feature/service does, which domain entities are involved.
2. **Define the project structure**: create all necessary directories and empty `__init__.py` / `index.ts` files so the skeleton is visible.
3. **Define domain entities** (`dataclass` / `interface`): fields, value objects, enums. No logic yet — only data shapes.
4. **Define ports** (interfaces / protocols): describe every external dependency the domain needs (repositories, gateways, clients) as abstract contracts with method signatures and type annotations. No implementations.
5. **Define DTOs and use-case signatures**: write use-case classes/functions with full type signatures and docstrings, but method bodies are `raise NotImplementedError` / `throw new Error("not implemented")`.

After Phase 1 the entire public surface of the feature is readable and reviewable without a single line of real logic.

## Phase 2 — Tests

6. **Write unit tests for use-cases**: mock all ports, test business rules, edge cases, and error paths. Tests must compile and **fail** (red phase).
7. **Write integration tests** (if applicable): test adapters against real infrastructure (DB in testcontainers, HTTP mocks). These also fail at this point.
8. **Run the full test suite** to confirm everything fails for the right reasons (not import errors or typos).

## Phase 3 — Implementation

9. **Implement domain logic**: fill in entity methods, validation, domain services. Re-run unit tests — some start passing.
10. **Implement use-cases**: orchestrate domain logic, call ports. Re-run unit tests — all should pass.
11. **Implement infrastructure adapters**: repositories, API clients, queue consumers. Re-run integration tests — should pass.
12. **Implement presentation layer**: HTTP handlers / CLI / event listeners. Wire everything in composition root (`main.py` / `app/providers`).

## Phase 4 — Verify & Refine

13. **Run the entire test suite** — everything green.
14. **Lint & format**: `ruff check . --fix`, `ruff format .` (Python) / `eslint --fix`, `prettier --write` (JS/TS).
15. **Review**: check naming, remove dead code, verify no layer violations (domain must not import infra).

## Key Principles

- **No forward jumps**: never write adapter code before its port exists and is tested.
- **Tests document behavior**: if a test doesn't exist for a behavior, that behavior is undefined.
- **Fail fast**: run tests after every phase. Fix compilation/import errors immediately.
- **Small commits per phase**: each phase is a logical commit boundary.
