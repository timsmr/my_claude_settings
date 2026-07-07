---
paths:
  - "**/*.py"
---

# Python Testing

## Test Structure
Every test is a plain function prefixed `test_` — no `class TestSomething`, no
`unittest.TestCase`. Use explicit section markers:

```python
def test_order_creation_validates_items(mock_repo: MagicMock) -> None:
    # Arrange
    items = [OrderItem(name="Widget", qty=1)]

    # Act
    result = create_order(items, repo=mock_repo)

    # Assert
    assert result.status == OrderStatus.Created
```

STRICT RULE: no docstrings in test functions — the name must be self-documenting
(`test_inference_filters_very_low_from_published_events`).

## Test Levels

```
tests/
    unit/           — fast, no I/O, pure logic, mocked dependencies
    integration/    — use-case tests (real domain logic + mocked infrastructure)
                      and adapter tests against real infra (testcontainers,
                      marked @pytest.mark.integration)
    e2e/            — full pipeline, end-to-end scenarios
    conftest.py     — root-level shared fixtures
```

Use-case tests that wire real domain logic but mock infrastructure go in
`tests/integration/`, not `tests/unit/`.

## What to Mock
STRICT RULE: never mock domain logic. Only mock infrastructure (DB gateways, API
clients, message publishers, file storage). Async ports are mocked with `AsyncMock`.

Good — real domain object, mocked infra:
```python
use_case = InferenceUseCase(
    enricher=Enricher(config),
    inference_gateway=AsyncMock(),
    publisher=AsyncMock(),
)
```
Bad — everything mocked: the test only asserts `mock.assert_called_once()` and
verifies nothing.

## No Hardcoded Thresholds
Test data derives values from config fixtures, never hardcoded magic numbers:

```python
cfg = enricher_obj.config
below = cfg.very_low_attempts_threshold - 1
df = pd.DataFrame([_raw_row(count_unsuccessful=below)])
```

## No Exact String Matching for Generated Output
Assertions on generated strings (queries, formatted output) check field presence,
not exact equality — templates may change format without breaking semantics.
Good: `assert "dst-1" in query`; bad: `assert query == "BF dst-1 src-1 admin"`.

## Async Tests
Use pytest-asyncio with the project's configured asyncio mode; do not sprinkle
per-test event-loop hacks.

## Fixtures
All fixtures live in a single root `tests/conftest.py` — mocks, fakes, helpers and
per-level fixtures all go there. Do NOT scatter `conftest.py` into subfolders.
Never define fixtures inside test files.
