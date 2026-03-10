---
paths:
  - "tests/**/*.py"
  - "test/**/*.py"
  - "**/test_*.py"
---

# Python Testing Guidelines

## Testing Best Practices

**Fixtures:** Put all fixtures in `conftest.py` — pytest discovers them automatically across the test suite without any imports.

**Mocking:** Use `@patch` as a decorator, not as a context manager — it keeps teardown automatic and avoids extra indentation nesting.

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

**Test against specification:** If a spec, PRD, or requirements doc exists for the feature being tested, read it before writing tests — derive test cases directly from the specified behaviour, not just from the implementation. Tests that only reflect the code can't catch the code being wrong.

**Test thoroughly:** Tests must be complete in two ways:
- **Scenario coverage** — cover all meaningful input combinations; no redundant cases, no gaps
- **Assertion completeness** — assert the full expected outcome per scenario, not a partial slice. When the expected result is a group (e.g., multiple disabled features, multiple called services), assert the entire group.

```python
# ❌ BAD: Asserts only one item from the expected group
("admin_disabled", "login_page"),  # but admin_api is also disabled

# ✅ GOOD: Asserts the complete expected group
("admin_disabled", ["login_page", "admin_api", "user_mgmt"]),
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

- Unit tests: Test individual functions/methods in isolation
- Integration tests: Test component interactions
- End-to-end tests: Test complete user workflows
- Tests mirror the `src/` folder structure
- Use `conftest.py` for shared fixtures
- Prioritize coverage of critical paths and business logic
