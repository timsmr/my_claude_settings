---
name: scaffold-python-service
description: Scaffold a new Python service, worker, or module in the hexagonal (ports & adapters) layout — full directory tree, pydantic-settings Config recipes, dishka DI wiring, create_app/main.py entrypoint templates. Use when creating a new Python service/worker/module skeleton from scratch, or when deciding where a new file belongs in the hexagonal layout.
---

# Scaffold a Python Service

Strict rules live in `python-services-architecture.md` (rules); this skill is the
concrete blueprint. Ports exist only for infrastructure dependencies; use-cases are
injected as concrete classes.

## Directory Tree

```
src/<service_name>/
    domain/                — created ONLY when real domain logic exists
        entities/          — dataclasses, value objects, aggregates
        errors.py          — domain-only exceptions (raised AND handled inside domain)
        services/          — domain services (pure logic, no other layers)
    application/
        ports/             — infrastructure-dependency ports, one file per port
        use_cases/         — orchestration of business logic
        errors.py          — errors that cross the port boundary (infra raises → presentation maps)
        dto.py             — DTOs and shared enums between layers
    infrastructure/
        <adapter>.py       — port implementations directly here (llm.py, cache.py, …); NO adapters/ subfolder
        config.py          — connector configs (BaseSettings)
        di/providers.py    — dishka providers
    presentation/
        api/
            app.py         — create_app() factory: builds FastAPI, wires routers + handlers
            health.py      — local /health endpoint (do not import a shared one)
            v1/            — versioned HTTP handlers
        schemas.py         — Pydantic request/response models
    config.py              — global Config, composes sub-configs
    main.py                — main() -> None; ends with `if __name__ == "__main__": main()`
tests/                     — single root conftest.py; unit/ integration/ e2e/ (see python-testing.md)
```

Proxy/gateway service with no real domain logic → no `domain/` layer at all.

## Port + Adapter

```python
from typing import Protocol


class OrderRepositoryPort(Protocol):
    """Persistence contract for orders."""

    async def get_by_id(self, order_id: OrderId) -> Order | None: ...
    async def save(self, order: Order) -> None: ...
```

Adapter explicitly inherits: `class PostgresOrderRepository(OrderRepositoryPort)`.

## Use-Case

```python
class CreateOrderUseCase:
    """Orchestrate order creation flow."""

    def __init__(self, orders: OrderRepositoryPort, payment: PaymentGatewayPort) -> None:
        self._orders = orders
        self._payment = payment
```

Injected into handlers as the concrete class — no inbound use-case port.

## Global Config

```python
from pydantic import Field
from pydantic_settings import BaseSettings


class Config(BaseSettings):
    """Global configuration for the service."""

    name: str = Field(default="my-service", alias="SERVICE_NAME")
    host: str = Field(default="0.0.0.0", alias="HOST")
    port: int = Field(default=8000, alias="PORT")
    llm_cfg: LLMConfig = Field(default_factory=LLMConfig)

    def to_log(self) -> dict[str, object]:
        """Present application parameters in log."""
        return {
            "application": {"name": self.name, "host": self.host, "port": self.port},
            "llm": self.llm_cfg.to_log(),
        }
```

## Connector Config

```python
from pydantic import Field
from pydantic_settings import BaseSettings


class LLMConfig(BaseSettings):
    """Upstream LLM connection and retry parameters."""

    base_url: str = Field(default=..., alias="LLM_BASE_URL")
    api_key: str = Field(default=..., alias="LLM_API_KEY")
    max_retries: int = Field(default=5, alias="LLM_MAX_RETRIES")

    def to_log(self) -> dict[str, object]:
        """Present LLM parameters in log, masking the secret key."""
        return {"base_url": self.base_url, "api_key_set": bool(self.api_key), "max_retries": self.max_retries}
```

`Field(default=..., alias=...)` (Ellipsis) marks required env params. No
`SettingsConfigDict(env_file=...)`.

## Domain Config (only if domain/ exists)

```python
from dataclasses import dataclass
from decimal import Decimal


@dataclass(frozen=True, slots=True)
class OrderPolicyConfig:
    """Business rules for order processing."""

    max_items_per_order: int = 100
    free_shipping_threshold: Decimal = Decimal("50.00")
```

## Entrypoint

- `presentation/api/app.py`: `create_app(...) -> FastAPI` — registers exception
  handlers, mounts routers, returns the app; no business wiring beyond DI setup.
- `main.py`: builds `Config`, configures logging
  (`logger.info("starting", config=config.to_log())`), builds the dishka container
  (`Config` via `from_context`), calls `create_app`, runs
  `uvicorn.run(app, host=config.host, port=config.port)`.
- Providers in `infrastructure/di/providers.py`; handlers get deps via
  `FromDishka[...]` + `@inject`; adapters needing cleanup are async-generator
  providers (`yield adapter; await adapter.close()`).
- Add a `[project.scripts]` entry; run via `python -m <service>.main`.
