# Frontend Architecture — Feature-Sliced Design (FSD)

All frontend projects follow **Feature-Sliced Design v2.x** methodology.
Reference: https://feature-sliced.design

## Layers (top → bottom)

Modules on a layer can only import from layers **strictly below**.

1. **app** — routing, providers, global styles, entrypoints. No slices — segments directly.
2. **pages** — full pages or large route-level parts. Each page is a slice.
3. **widgets** — large self-contained UI blocks delivering an entire use case. Each widget is a slice.
4. **features** — reusable user actions that bring business value (e.g., `add-to-cart`, `auth-by-phone`). Each feature is a slice.
5. **entities** — core business objects (`user`, `product`, `order`). Each entity is a slice.
6. **shared** — reusable code detached from business logic (UI kit, API client, libs, config). No slices — segments directly.

## Segments inside a Slice

```
features/
  add-to-cart/
    ui/           — components, styles
    model/        — stores, schemas, business logic
    api/          — backend interactions, mappers
    lib/          — helper utilities local to this slice
    config/       — feature flags, constants
    index.ts      — public API (re-exports only)
```

## Strict Rules

- **Public API**: every slice exposes only an `index.ts` barrel file. No deep imports.
- **No cross-imports on the same layer**: `features/A` must not import from `features/B`. Extract shared logic down to `entities` or `shared`.
- **Import direction**: always top → down. `pages → widgets → features → entities → shared`. Never reverse.
- **`app` and `shared`** have no slices — only segments (`ui/`, `api/`, `lib/`, `config/`, etc.).

## Naming

- Layers and slices: `kebab-case` folders (`add-to-cart`, `user-profile`).
- Segments: `kebab-case` (`ui`, `model`, `api`, `lib`, `config`).
- Components: `PascalCase` files (`AddToCartButton.tsx`).

## Structure Example

```
src/
  app/
    providers/
    routes/
    styles/
    index.tsx
  pages/
    home/
      ui/
      index.ts
    product-detail/
      ui/
      api/
      model/
      index.ts
  widgets/
    header/
      ui/
      index.ts
    product-card/
      ui/
      model/
      index.ts
  features/
    add-to-cart/
      ui/
      model/
      api/
      index.ts
    auth-by-email/
      ui/
      model/
      api/
      index.ts
  entities/
    user/
      ui/
      model/
      api/
      index.ts
    product/
      ui/
      model/
      api/
      index.ts
  shared/
    ui/
    api/
    lib/
    config/
```
