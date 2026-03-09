---
paths:
  - "tests/**/*.py"
  - "test/**/*.py"
---

# Testing Guidelines

Pytest conventions covering fixtures, mocking, and parametrize usage.

## 🧪 Testing Strategy

### Testing Best Practices

**Fixtures:** All fixtures must be in `conftest.py`

**Mocking:** Use `@patch` as decorator, NOT as context manager

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

### Test Organization

- Unit tests: Test individual functions/methods in isolation
- Integration tests: Test component interactions
- End-to-end tests: Test complete user workflows
- Tests live in `tests/unit/` directory, mirroring the `src/` folder structure
- Use `conftest.py` for shared fixtures
- Aim for 80%+ code coverage, but focus on critical paths
