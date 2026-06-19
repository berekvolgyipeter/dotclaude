# Python Testing Rules

## Core Principle

Tests verify observable **behavior through public interfaces**, never implementation details — a good test reads like a specification and survives an internal refactor. If a test breaks when you rename a private method or change an internal call sequence without changing behavior, it was testing implementation: rewrite it. Don't assert call counts/order, don't test private methods, and don't verify through a side channel (e.g. querying the database directly) instead of through the interface.

## Testing Best Practices

**Fixtures:** Put all fixtures in `conftest.py` — pytest discovers them automatically across the test suite without any imports.

**Mocking:** Mock only at system boundaries — external APIs, the database, the network, the filesystem, time, and randomness. Never mock your own modules or internal collaborators; doing so couples the test to implementation and is the surest sign of a brittle test. When you do patch a boundary, use `@patch` as a decorator, not a context manager — it keeps teardown automatic and avoids extra indentation nesting.

**Arrange-Act-Assert (AAA):** Structure every test in three phases — Arrange (set up preconditions), Act (execute the code under test), Assert (verify the outcome). Keep each phase visually distinct; a blank line between them is enough.

**One behavior per test:** Each test should verify exactly one behavior, making failures easy to diagnose. If a test name requires "and", split it into two tests.

**Test error paths:** Always test failure cases, not just the happy path. For each function under test, consider what can go wrong — invalid input, missing resources, boundary conditions — and assert the expected exception or error response with `pytest.raises(SomeError, match="...")`.

**Parametrize over duplicating test methods:** When multiple tests differ only in input data and expected output, use `@pytest.mark.parametrize` instead of writing separate test methods. This produces more rigorous coverage with less code and is easier to extend.

```python
# ❌ BAD: Separate test methods that only differ in input/output
def test_parse_lower(self):
    assert parse("hello") == "HELLO"

def test_parse_mixed(self):
    assert parse("Hello") == "HELLO"

# ✅ GOOD: Parametrized test
@pytest.mark.parametrize(
    ("input_val", "expected"),
    [("hello", "HELLO"), ("Hello", "HELLO"), ("HELLO", "HELLO"), ("other", "OTHER")],
    ids=["lowercase", "mixedcase", "uppercase", "other"],
)
def test_parse(self, input_val, expected):
    assert parse(input_val) == expected
```

**Test against specification:** If a spec, plan, or requirements doc exists for the feature being tested, read it before writing tests — derive test cases directly from the specified behaviour, not just from the implementation. Tests that only reflect the code can't catch the code being wrong.

**Test thoroughly:** Tests must be complete in two ways:
- **Scenario coverage** — cover all meaningful input combinations; no redundant cases, no gaps
- **Assertion completeness** — assert the full expected outcome per scenario, not a partial slice. When the expected result is a group (e.g., multiple disabled features, multiple called services), assert the entire group.

```python
# ❌ BAD: Asserts only one item from the expected group
("admin_disabled", "login_page"),  # but admin_api is also disabled

# ✅ GOOD: Asserts the complete expected group
("admin_disabled", ["login_page", "admin_api", "user_mgmt"]),
```

**Independent test constants:** Never import production constants to use as expected values in assertions — if the production value changes to garbage, the test must catch it. Hardcode expected values in a dedicated test constants file (e.g., `tests/**/constants.py`).

```python
# ❌ BAD — test mirrors whatever production says
from src.config import ERROR_TEMPLATE

assert format_error("oops") == ERROR_TEMPLATE.format(msg="oops")

# ✅ GOOD — independent expected value catches regressions
from tests.constants import EXPECTED_ERROR_TEMPLATE

assert format_error("oops") == EXPECTED_ERROR_TEMPLATE.format(msg="oops")
```

**Mirror real calling patterns:** Test setups should invoke code the same way production does — use the same constructors, factory methods, or entry points that production code uses, not shortcuts or equivalents.

```python
# ❌ BAD — bypasses the factory, misses production wiring
obj = MyService.__new__(MyService)
obj._client = mock_client

# ✅ GOOD — uses the same entry point as production
obj = MyService.create(config=test_config, client=mock_client)
```

**Env vars in `pyproject.toml`:** Set all environment variables required by unit tests under `[tool.pytest.ini_options]` `env` in `pyproject.toml` — never set them inline in test files, fixtures, or shell wrappers. If the project does not use `pyproject.toml`, declare them in `pytest.ini` under `[pytest]` `env` instead. This keeps the test environment reproducible and discoverable in one place. Sensitive values (API keys, credentials, tokens) must never be hardcoded — mock them with dummy placeholders.

> **Requires the `pytest-env` plugin.** Add it to the project's dev dependencies and ask the user to install. Without it, pytest silently ignores the `env` key. For per-test overrides, use `monkeypatch.setenv(...)` inside the test — that's the idiomatic carve-out.

```toml
# ✅ GOOD: env vars declared centrally, secrets mocked
[tool.pytest.ini_options]
env = [
    "APP_ENV=test",
    "DATABASE_URL=sqlite:///:memory:",
    "API_KEY=dummy-test-key",
]
```

```ini
# ✅ GOOD: same approach in pytest.ini when no pyproject.toml
[pytest]
env =
    APP_ENV=test
    DATABASE_URL=sqlite:///:memory:
    API_KEY=dummy-test-key
```

**DRY in tests:** Extract shared mock setup into `conftest.py` fixtures. If the same mock construction appears in multiple tests, it belongs in a fixture.

```python
# ✅ GOOD: Shared mock in conftest.py
@pytest.fixture
def sample_user():
    """Provide a sample user for testing."""
    return User(
        id=123,
        email="test@example.com"
    )
```

```python
# Use descriptive test names
def test_user_can_update_email_when_valid(sample_user):
    """Test that users can update their email with valid input."""
    new_email = "newemail@example.com"
    sample_user.update_email(new_email)
    assert sample_user.email == new_email

# Test edge cases and error conditions
def test_user_update_email_fails_with_invalid_format(sample_user):
    """Test that invalid email formats are rejected."""
    with pytest.raises(ValidationError) as exc_info:
        sample_user.update_email("not-an-email")
    assert "Invalid email format" in str(exc_info.value)
```

## Test Organization

- Unit tests: Verify a unit's behavior through its public interface — not private methods or internal call sequences
- Integration tests: Test module interactions
- End-to-end tests: Test complete user workflows
- Tests mirror the `src/` folder structure
- Use `conftest.py` for shared fixtures
- Prioritize coverage of critical paths and business logic
