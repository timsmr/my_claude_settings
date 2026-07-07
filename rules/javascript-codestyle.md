---
paths:
  - "**/*.{ts,tsx,js,jsx}"
---

# JavaScript / TypeScript Code Style

Formatting and import order are enforced by Prettier + ESLint — run `eslint --fix`
and `prettier --write` on the files you touched before finishing; rules below are
only what linters cannot express.

## TypeScript First
- All new code is TypeScript (`.ts`/`.tsx`), `strict: true`; no plain `.js` files.
- No `any` — use `unknown` and narrow with type guards.
- `interface` for object shapes, `type` for unions and intersections.

## Comments Policy
STRICT RULE: no inline `//` comments explaining "what" the code does.
- Code must be self-documenting through naming.
- JSDoc `/** ... */` only for public API of shared libraries; no `@param`/`@returns` —
  type annotations carry that information.
- Allowed exceptions: `// eslint-disable-next-line <rule>` and
  `// @ts-expect-error <reason>` with mandatory reason.

## Naming
- Files/folders: `kebab-case`; React component files: `PascalCase` when the file
  exports a single component.
- Booleans: `is`/`has`/`should`/`can` prefix. Constants: `UPPER_SNAKE`.
- Event handlers: `handle<Event>` (`handleClick`, `handleSubmit`).

## Functions & Exports
- `const fn = () => {}` for non-hoisted functions and callbacks; named `function`
  declarations for top-level hoisted functions and generators.
- No default exports — named exports only. Exception: framework contracts that
  require them (Next.js pages/layouts/route handlers, config files).
- Keep functions short — one level of abstraction per function.

## Imports
- Absolute imports via path aliases (`@/shared/ui`).
- Slice/layer import rules: see frontend-architecture.md.

## React
- Functional components only; hooks at the top, never conditional.
- Extract complex logic into custom hooks (`use-<name>.ts`).
- Props: `interface <Component>Props { ... }` directly above the component.
- No `useEffect` for derived state — `useMemo` or compute inline.

## Error Handling
- Domain errors as custom classes extending `Error`.
- API layer maps network errors to typed results (`Result<T, E>` or discriminated
  unions); no silent `catch {}` — log or propagate.

## Testing
- Vitest as the runner (unless the project already uses another — follow the
  project's runner); test files `*.test.ts(x)`.
- Same discipline as Python tests: plain test functions, self-documenting names,
  no exact-string assertions on generated output.
