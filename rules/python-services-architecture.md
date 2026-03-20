# Python Services Architecture

## Project Structure (Hexagonal / Ports & Adapters)

```
src/<service_name>/
    domain/
        entities/          — dataclasses, value objects, aggregates
        errors.py          — domain-specific exceptions
        ports.py           — abstract interfaces (protocols/ABCs)
    application/
        use_cases/         — orchestration of business logic
        dto.py             — data transfer objects between layers
    infrastructure/
        adapters/          — implementations of domain ports (DB, API clients, queues)
        config.py          — pydantic-settings based configuration
    presentation/
        api/               — HTTP handlers (FastAPI routers, etc.)
        schemas.py         — Pydantic request/response models
    main.py                — composition root, wiring everything together
tests/
    unit/                  — fast, no I/O, mocked dependencies
    integration/           — real DB/services in containers
    conftest.py
```

## Dependency Initialization
STRICT RULE: No instance creation inside classes.

All instances are created in `main.py` (composition root) and passed as constructor arguments.
A class never does `self._repo = SomeRepository()` inside `__init__`.

Good:
```python
@dataclass
class CreateOrderUseCase:
    """Orchestrate order creation flow."""

    order_repo: OrderRepository
    payment: PaymentGateway
```

Bad:
```python
class CreateOrderUseCase:
    def __init__(self) -> None:
        self._order_repo = SQLAlchemyOrderRepository()
        self._payment = StripePaymentClient()
```

## Ports (Domain Interfaces)
Ports are defined in the domain layer as `Protocol` or `ABC`. They describe **what** the domain needs, not **how** it's implemented.

```python
from typing import Protocol


class OrderRepository(Protocol):
    """Persistence contract for orders."""

    async def get_by_id(self, order_id: OrderId) -> Order | None: ...
    async def save(self, order: Order) -> None: ...


class PaymentGateway(Protocol):
    """External payment processing contract."""

    async def charge(self, amount: Decimal, token: str) -> PaymentResult: ...
```

Adapters in `infrastructure/` implement these ports. The domain layer never imports from infrastructure.

## Configuration

### Application & Infrastructure
Use `pydantic-settings` for all configuration outside of domain modules.

```python
from pydantic_settings import BaseSettings, SettingsConfigDict


class DatabaseSettings(BaseSettings):
    """Database connection parameters."""

    model_config = SettingsConfigDict(env_prefix="DB_")

    host: str = "localhost"
    port: int = 5432
    name: str
    user: str
    password: str

    @property
    def dsn(self) -> str:
        return f"postgresql+asyncpg://{self.user}:{self.password}@{self.host}:{self.port}/{self.name}"
```

### Domain Config
Domain modules must NOT depend on `pydantic-settings`. Use `dataclasses` to keep the domain layer free of infrastructure dependencies.

```python
from dataclasses import dataclass
from decimal import Decimal


@dataclass(frozen=True)
class OrderPolicyConfig:
    """Business rules for order processing."""

    max_items_per_order: int = 100
    auto_cancel_after_minutes: int = 30
    free_shipping_threshold: Decimal = Decimal("50.00")
```

### Composition Root
Settings are instantiated in `main.py` and injected into services/use-cases. Classes never read environment variables directly.

## Adapter Responsibility
STRICT RULE: Infrastructure adapters return raw data only. No domain-specific filtering or transformation.

Allowed:
```python
def fetch_events(self, time_from: datetime, time_to: datetime) -> pl.DataFrame:
    """Fetch raw events from ClickHouse."""
    data = self.client.execute(query)
    return pl.DataFrame(data, schema=columns)
```

Forbidden:
```python
def fetch_events(self, time_from: datetime, time_to: datetime) -> pl.DataFrame:
    """Fetch events and apply domain filtering."""
    data = self.client.execute(query)
    df = pl.DataFrame(data, schema=columns)
    return df.filter(pl.col("score") > self.threshold)
```

Data flow: infrastructure (raw) → use-case (orchestration) → domain (processing).

## Constructor vs Method Parameters
- `__init__`: static dependencies (config, locales, ports, clients)
- Method parameters: runtime data (raw DB results, user input, request payload)

```python
class ProcessTreeBuilder:
    def __init__(self, locales: dict, config: TreeBuilderConfig) -> None: ...
    def build(self, nodes: list[ProcessNode], raw_modules: pl.DataFrame) -> str: ...
```

## DTO Placement
Use-case result DTOs (e.g. `AnalysisResult`) belong in `application/` (ports or dto.py), NOT in `domain/`.
Domain layer contains only entities, value objects, and domain logic.

## Constants Placement
Constants live in the layer that uses them.
- Domain constants → `domain/config.py` (as dataclass fields)
- Infrastructure constants (e.g. `MODULE_DEFINITIONS`) → infrastructure layer
- Never place infrastructure constants in domain.

## Configuration Objects
Prefer structured objects over raw dicts for configuration.
- Domain layer: only native stdlib (`dataclasses`, `NamedTuple`). No pydantic, no third-party.
- Application / Infrastructure / Presentation: pydantic, pydantic-settings, attrs and other libraries are fine.

## Layer Dependency Rules
- `domain` → imports nothing outside domain (no framework, no infra).
- `application` → imports from `domain` only.
- `infrastructure` → imports from `domain` and `application`.
- `presentation` → imports from `application` (and `domain` types if needed).
- `main.py` → imports everything, wires the graph.
