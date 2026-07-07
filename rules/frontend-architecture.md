---
paths:
  - "**/*.{ts,tsx,js,jsx}"
---

# Frontend Architecture — Feature-Sliced Design v2.x

All frontend projects follow FSD v2.x (https://feature-sliced.design).
In an existing non-FSD codebase, follow the project's layout; FSD governs new
projects and new top-level slices.

- Layers top → down: `app → pages → widgets → features → entities → shared`.
  A module imports only from layers strictly below, never sideways or up.
- No same-layer cross-imports: `features/A` must not import `features/B` —
  extract shared logic down to `entities` or `shared`.
- Every slice exposes a single public API (`index.ts` barrel); no deep imports
  past it. Barrels only at the slice boundary, not inside.
- `app` and `shared` have no slices — segments directly.
- Segments inside a slice: `ui/`, `model/`, `api/`, `lib/`, `config/`.
- Naming: layers/slices/segments `kebab-case`; component files `PascalCase`.
