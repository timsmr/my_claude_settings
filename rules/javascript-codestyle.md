# JavaScript / TypeScript Code Style

## TypeScript First
- All new code is written in TypeScript (`.ts` / `.tsx`). No plain `.js` files in the project.
- `strict: true` in `tsconfig.json`. No `any` — use `unknown` and narrow with type guards.
- Prefer `interface` for object shapes, `type` for unions and intersections.

## Comments Policy
STRICT RULE: No inline comments with `//` explaining "what" the code does.
- Code must be self-documenting through naming.
- JSDoc `/** ... */` only for public API of shared libraries. No `@param` / `@returns` — use type annotations.
- Only allowed exception: `// eslint-disable-next-line <rule>` or `// @ts-expect-error <reason>` with mandatory reason.

## Naming
- Files/folders: `kebab-case` (`user-profile.ts`, `use-auth.ts`).
- React components: `PascalCase` files (`UserProfile.tsx`) when the file exports a single component.
- Variables/functions: `camelCase` (`getUserById`, `isActive`).
- Constants: `UPPER_SNAKE` (`MAX_RETRY_COUNT`, `API_BASE_URL`).
- Types/interfaces: `PascalCase` (`UserProfile`, `OrderStatus`).
- Enums: `PascalCase` name, `PascalCase` members (`enum OrderStatus { Pending, Confirmed }`).
- Boolean variables/props: prefix with `is`, `has`, `should`, `can` (`isLoading`, `hasAccess`).

## Functions
- Prefer `const fn = () => {}` for non-hoisted functions and callbacks.
- Use named `function` declarations for top-level hoisted functions and generators.
- No default exports. Always use named exports: `export const UserCard = ...`, `export function createOrder(...)`.
- Keep functions short — one level of abstraction per function.

## Imports
- All imports at the top of the file.
- Order (automated via ESLint/Prettier):
  1. Node built-ins / framework (`react`, `next`)
  2. Third-party packages
  3. Project aliases (`@/shared`, `@/entities`, etc.)
- Absolute imports via path aliases (`@/shared/ui`). No relative imports crossing slice boundaries.
- No barrel re-exports (`index.ts`) inside a slice — only at the slice boundary (public API).

## Async
- Prefer `async/await` over raw Promises and `.then()` chains.
- Always handle errors: `try/catch` or `.catch()`. No unhandled promise rejections.
- Parallel independent requests: `Promise.all()` or `Promise.allSettled()`.

## React Specific
- Functional components only. No class components.
- Hooks at the top of the component, no conditional hooks.
- Extract complex logic into custom hooks (`use-<name>.ts`).
- Props: define as `interface <Component>Props { ... }` directly above the component.
- Avoid `useEffect` for derived state — use `useMemo` or compute inline.
- Event handlers: `handle<Event>` naming (`handleClick`, `handleSubmit`).

## Error Handling
- Domain errors as custom classes extending `Error`.
- API layer catches network errors and maps them to typed results (`Result<T, E>` or discriminated unions).
- No silent `catch {}` blocks — always log or propagate.

## Formatting & Linting
- Prettier for formatting (printWidth: 100, singleQuote: true, trailingComma: "all").
- ESLint for code quality.
- No `eslint-disable` without a reason comment.

## Immutability
- Prefer `const` over `let`. Never use `var`.
- Don't mutate function arguments. Return new objects/arrays.
- Use spread (`{ ...obj }`, `[...arr]`) or `structuredClone()` for copies.
