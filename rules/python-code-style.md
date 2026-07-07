---
paths:
  - "**/*.py"
---

# Python Code Style

Naming, import order, formatting, line length, annotations coverage: enforced by
ruff/mypy — run `ruff check --fix` + `ruff format` on the files you touched before
finishing; rules below are only what linters cannot express.

## Comments
STRICT RULE: No inline `#` comments.
- Code must be self-documenting through names and docstrings; if logic needs a
  comment — refactor: extract a named function.
- Files must not start with comments or module docstrings ("""Module that does X.""");
  start directly with imports. Module docstrings only for genuinely non-obvious public API.
- Allowed exceptions: `# type: ignore[<reason>]` with mandatory reason;
  `# Arrange` / `# Act` / `# Assert` markers in tests (see python-testing.md).

## Docstrings
Mandatory for all production functions/methods; English (test functions: see
python-testing.md). Content: only what the function does — no Args/Returns/Raises/Yields
sections ever; types carry that information. Multi-sentence allowed for non-obvious
behavior, vague name-restating one-liners are not.

```python
def calculate_total(items: list[OrderItem], discount: float = 0.0) -> Decimal:
    """Calculate the total order amount after applying a discount."""
```

## Typing
- Never `Any` in annotations — use `object` for generic kwargs (`**overrides: object`).
- No `from __future__ import annotations` unless a real circular import requires it.
- Domain entities: stdlib `dataclass` — pydantic never in domain; other layers may
  use it (see python-services-architecture.md).

## Imports
Absolute imports only — in src-layout they start with the package name, never with
dots. All imports at the top of the file; no try/except around imports.

## Logging
`from structlog import get_logger`, then `logger = get_logger()` — never
`import structlog` + `structlog.get_logger()`. If the project provides a shared
logging package, use its `get_logger` instead.
Log calls: constant event name + kwargs — `logger.info("order_created", order_id=order.id)`.
Never f-strings inside log messages.

## Misc
- Methods that don't use `self` → `@staticmethod` (private and public alike).
- Your change must not leave unused functions/imports/variables behind; pre-existing
  dead code stays unless asked (see change-discipline.md).
- Re-raise with context: `raise DomainError(...) from err`.
- No bare `except:` / `except Exception:` without logging.
- I/O is `async/await`; don't mix sync and async I/O in one module without clear need.
- Exceptions live in the `errors.py` of the layer that owns them
  (see python-services-architecture.md).
