# Python Testing

## Test Structure
Every test is a plain function (no classes). Use explicit section markers:

```python
def test_order_creation_validates_items(mock_repo: MagicMock) -> None:
    """Validate that order creation checks item constraints."""
    # Arrange
    items = [OrderItem(name="Widget", qty=1)]

    # Act
    result = create_order(items, repo=mock_repo)

    # Assert
    assert result.status == OrderStatus.Created
```

## Test Levels

```
tests/
    unit/           — fast, no I/O, mocked dependencies
    integration/    — real DB/services in containers
    e2e/            — full pipeline, end-to-end scenarios
    conftest.py     — root-level shared fixtures
```

## Fixtures
All fixtures live in `conftest.py` at the appropriate level:
- `tests/conftest.py` — shared across all levels (mocks, common helpers)
- `tests/unit/conftest.py` — unit-specific fixtures
- `tests/integration/conftest.py` — DB clients, service configs
- `tests/e2e/conftest.py` — end-to-end infrastructure

Never define fixtures inside test files.

## Test Functions, Not Classes
STRICT RULE: All tests are plain functions prefixed with `test_`.
No `class TestSomething`. No `unittest.TestCase`.
