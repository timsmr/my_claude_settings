---
paths:
  - "**/*.py"
---

# Python Services Architecture (Hexagonal / Ports & Adapters)

Scaffolding a new service or module? Use the `scaffold-python-service` skill
(directory tree + config/DI/entrypoint recipes live there).

## Layer Rules
Imports (static): `domain` imports nothing outside domain; `application` imports
`domain` only; `infrastructure` imports `application` + `domain`; `presentation`
imports `application` (+ `domain` types); `main.py` imports everything and wires the graph.

Injection (runtime): domain services → into use-cases; infrastructure adapters →
into use-cases (typed by their ports); use-cases → into presentation handlers.

All domain logic lives in `domain/`: logic is "domain" when it needs no other layer.
The moment it calls a port or another layer, it is application logic.

Placement: use-cases in `application/use_cases/`; adapters directly in
`infrastructure/<adapter>.py` (NO `adapters/` subfolder); domain-only exceptions
(raised AND handled inside domain) in `domain/errors.py`.
- No real domain logic (proxy/gateway service)? Do not create `domain/` at all —
  entities and errors live in `application/`.
- Errors that cross the port boundary (infra raises → presentation maps) live in
  `application/errors.py`, never in `domain/`.

## Ports
Ports (`Protocol`, suffixed `Port`) exist ONLY for infrastructure dependencies
(DB, LLM, queues, storage, …). They describe **what** is needed, not **how**.
- `application/ports/` is a package with one file per port (`ports/llm.py`,
  `ports/inmemory_cache.py`).
- Adapters explicitly inherit their port: `class LLM(LLMPort)`.
- Use-cases are injected into presentation as concrete classes — no inbound
  use-case ports, no `domain/ports/`.
- Port signatures use domain/application types (enums, dataclasses), never raw
  primitives; the adapter extracts `.value`/`.name` when formatting queries.

## Dependency Initialization
STRICT RULE: no instance creation inside classes. All instances are created in the
composition root and passed as constructor arguments — a class never does
`self._repo = SomeRepository()` in `__init__`.
- Explicit `__init__` storing deps as private attributes (`self._x`), not a `@dataclass`.
- Name each dependency by its role (`llm`, not `backend`).
- `__init__` takes static dependencies (config, ports, clients); method parameters
  take runtime data (user input, request payload, raw DB results).
- Merge closely related use-cases into one class with several public methods
  sharing private helpers.

## Adapter Responsibility
STRICT RULE: infrastructure adapters return raw data only — no domain-specific
filtering or transformation inside adapters.
Data flow: infrastructure (raw) → use-case (orchestration) → domain (processing).
Every external I/O call sets an explicit timeout; retry/backoff policies are
config fields, never hardcoded.

## Configuration
- Global config: class `Config(BaseSettings)` in `config.py` next to `main.py`,
  composes sub-configs via `Field(default_factory=...)`, exposes
  `to_log() -> dict[str, object]`.
- Each infrastructure connector has its own `BaseSettings` config in
  `infrastructure/config.py`. Env params: `Field(alias="ENV_NAME")`; required
  params: `Field(default=..., alias=...)` (Ellipsis → must be set). Do NOT set
  `model_config = SettingsConfigDict(env_file=...)`. Every config has `to_log()`
  with secrets masked (`"api_key_set": bool(self.api_key)`).
- Domain config (if any): frozen slotted stdlib `dataclass` — domain never depends
  on pydantic-settings. Other layers may use pydantic/attrs freely.
- `Config` is instantiated once in `main()` and enters the DI container via
  `from_context`; classes never read environment variables directly.
- Tunable numbers (retries, backoff, timeouts, cache sizes) are config fields
  injected via `__init__`, never module-level constants like `MAX_RETRIES = 5`.
  Other constants live in the layer that uses them; infrastructure constants
  never live in domain.

## DTO Placement
Use-case result DTOs belong in `application/dto.py`, not in `domain/`. Enums shared
across application/infrastructure also belong in `application/dto.py`, never in
`config.py` (config imports infra dependencies).

## DI (dishka) & Entrypoint
- Providers live in `infrastructure/di/providers.py`; never stash objects on `app.state`.
- HTTP handlers receive dependencies via `FromDishka[...]` + `@inject`.
- Adapters needing cleanup are provided as async generators
  (`yield adapter; await adapter.close()`), finalized on container close.
- `presentation/api/app.py` exposes `create_app() -> FastAPI`; `main.py` exposes
  `def main() -> None` and ends with `if __name__ == "__main__": main()`.
- Run via `python -m` / `[project.scripts]`, NOT `uvicorn module:app`.
