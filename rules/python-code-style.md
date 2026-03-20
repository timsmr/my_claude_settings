# Python Code Style

## Comments
STRICT RULE: No inline comments with `#`.
- Code must be self-documenting through function/variable names and docstrings.
- Files must not start with comments or descriptions. No `"""Module that does X."""` at the top. Start directly with imports.
- Module-level docstrings are only allowed when the module contains non-obvious public API that genuinely needs a top-level explanation.
- If logic requires a comment — refactor: extract into a named function.
- Only allowed exception: `# type: ignore[<reason>]` with mandatory reason.

## Docstrings
Mandatory for all functions and methods. Language: English.

Docstring contains ONLY a clear description of what the function does. No `Args`, no `Returns`, no `Raises`, no `Yields` sections. All parameter and return type information belongs exclusively in type annotations.

Good:
```python
def calculate_total(items: list[OrderItem], discount: float = 0.0) -> Decimal:
    """Calculate the total order amount after applying a discount."""
```

Bad — contains parameter/return/raises documentation:
```python
def calculate_total(items: list[OrderItem], discount: float = 0.0) -> Decimal:
    """Calculate the total order amount after applying a discount.

    Args:
        items: list of order line items.
    Returns:
        Total amount after the discount is applied.
    """
```

Bad — vague, restates the function name:
```python
def calculate_total(items: list[OrderItem], discount: float = 0.0) -> Decimal:
    """Calculate total."""
```

Multi-sentence docstrings are allowed for non-obvious behavior, but still no Args/Returns/Raises:
```python
def retry_payment(order: Order, strategy: RetryStrategy) -> PaymentResult:
    """Attempt to charge the customer again using the given retry strategy.

    Skips retry if the order has already been fully refunded or if the
    payment provider flagged the card as permanently declined.
    """
```

## Typing
- Always annotate function params and return values.
- Use `|` instead of `Union`: `str | None`, not `Optional[str]`.
- Built-in generics: `list[str]`, `dict[str, int]`, not `List`, `Dict`.
- Domain entities: `dataclass` or `attrs`. Pydantic: presentation/infrastructure only.

## Naming
- Modules/packages: `snake_case` (`order_repository.py`)
- Classes: `PascalCase` (`OrderRepository`)
- Functions/methods: `snake_case` (`get_by_id()`)
- Constants: `UPPER_SNAKE` (`MAX_RETRY_COUNT`)
- Private members: `_` prefix (`_validate_email()`)
- Type aliases: `PascalCase` (`UserId = NewType("UserId", str)`)

## Imports
STRICT RULE: All imports at the top of the file. No imports in the middle or end of code.
No `try/except` around imports — if an import fails, it must fail immediately.

Order (ruff sorts automatically):
1. Standard library
2. Third-party packages
3. Local project modules

**Absolute imports only.** In src-layout, imports start with the package name, never with dots.

Good:
```python
from user_service.domain.entities.user import User
from user_service.application.ports.user_repository import UserRepositoryPort
```

Bad:
```python
from ...domain.entities.user import User
from .infrastructure.config import DATABASE_URL
```

No wildcard imports (`from module import *`). Use explicit imports.

No `from __future__ import annotations` — the project targets Python 3.10+ where `X | Y` and built-in generics (`list[str]`, `dict[str, int]`) work natively. Only add this import when there is a real circular import that requires it.

## Logging
Use structlog with the following pattern:

```python
from structlog import get_logger

logger = get_logger()
```

Not: `import structlog` + `logger = structlog.get_logger()`.

## Static Methods
Methods that don't use `self` must be `@staticmethod`.
Applies to both private and public methods.

## Dead Code
STRICT RULE: No unused functions, methods, imports, or variables.
When consolidating methods (e.g. merging `fetch_inference` into `fetch_modules`), delete the old method entirely.

## Async
- Prefer `async/await` for I/O operations.
- Don't mix sync and async in one module without clear necessity.
- Parallel tasks: `asyncio.gather()` or `TaskGroup`.

## Error Handling
- Domain exceptions live in `domain/errors.py`.
- No bare `except:` or `except Exception:` without logging.
- f-strings for interpolation. Max line length: 120 chars.
- No mutable default arguments: `def foo(items: list = [])` is a bug.
