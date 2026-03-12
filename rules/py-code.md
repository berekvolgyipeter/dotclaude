---
paths:
  - "**/*.py"
---

# Python Developer Guidelines

## CRITICAL: KISS & YAGNI ENFORCEMENT

**DO NOT IMPLEMENT ANYTHING BEYOND WHAT IS EXPLICITLY REQUESTED.**

Before implementing anything, confirm:
1. Is this explicitly requested, or am I adding scope?
2. Have I used a tool to confirm the answer, or am I guessing?
3. Does this follow the existing pattern in the codebase?

Rules:
- Build ONLY what is asked for - nothing more
- Choose the simplest solution that works
- No speculative features or "nice-to-haves"
- No additional functionality "just in case"
- Stop when the requirement is met

---

## Core Development Philosophy

- **KISS**: Choose straightforward solutions over complex ones.
- **YAGNI**: Implement features only when needed, not in anticipation.
- **DRY**: Implement logic once; upper layers pass parameters through, not re-implement.
- **Single Responsibility**: Each function, class, and module has one clear purpose.
- **Fail Fast**: Raise exceptions immediately when issues occur.
- **No Mutation of Arguments**: Do not modify mutable arguments (lists, dicts, sets) in place — return new or modified values instead.
- **Dependency Inversion**: Depend on abstractions for service/module dependencies — not for configuration (see Configuration Extraction below).
- **Open/Closed**: Open for extension, closed for modification.

---

## Code Structure & Modularity

- **Max file length: 500 lines** — split into modules when approaching this limit
- **Max function length: 50 lines**
- **Max class length: 200 lines**
- Organize code into clearly separated modules grouped by feature or responsibility

---

## Style & Conventions

### File-level Symbol Ordering

**Do not interleave variables, classes, and functions** — group into contiguous sections:
1. Variables / constants
2. Classes
3. Functions

### Python Style

- **Follow PEP8** with: double quotes, trailing commas in multi-line structures
- **Always use type hints** for function signatures and class attributes
- **Use precise types** — avoid `Any` and `object`; prefer union types (`ModelA | ModelB | None`). `Any` is acceptable only at third-party library boundaries
- **Use modern 3.10+ type syntax** — `list[str]` not `List[str]`, `str | None` not `Optional[str]`
- **Format with `make lint`**
- **Use `pydantic` v2** for data validation and settings management
- **Always use keyword arguments** for optional parameters, not positional
- **f-strings only** — never `%` formatting or `.format()`
- **`pathlib` over `os.path`** for all file/path operations
- **`@property` not getter/setter methods** — `user.name`, not `user.get_name()`

### Commenting

**DO NOT comment obvious code.** Only comment business rules, workarounds, non-obvious decisions, or important side effects.

### Models and Dataclasses

- **Define models in dedicated modules** (`models/`, `schemas/`), never inline with business logic
- **Prefer dataclasses over complex nested return types** — use a named dataclass instead of `tuple[int, list[tuple[str, int]]]`
- **Pydantic models** for validation boundaries (API input/output, config, external data). **Dataclasses** for internal domain objects with no validation needs

### Enums

- **Use `StrEnum`/`IntEnum` for categorical values** — no magic strings scattered through code
- **Define enums close to their domain** — in the relevant `models/` or `enums.py` module
- **Use enums for any value that appears in comparisons, match/case, or is passed between functions**

```python
# ❌ BAD — magic strings
if order.status == "pending": ...

# ✅ GOOD — enum for categorical values
class OrderStatus(StrEnum):
    PENDING = "pending"
    COMPLETED = "completed"

if order.status == OrderStatus.PENDING: ...
```

### Configuration Extraction

- **Extract magic values to a config module** — never hardcode in functions
- **App-layer functions** read config internally; **pure/utility functions** take parameters for testability:

```python
# App-layer — reads config internally
def process_orders():
    threshold = settings.ORDER_THRESHOLD
    ...

# Pure/utility — takes parameters, no config dependency
def filter_orders(orders: list[Order], threshold: int) -> list[Order]:
    ...
```

### Imports

- Always at the top of the file, ordered: stdlib → third-party → local
- **Use absolute imports** — never relative (`from ..utils import x`)
- **No wildcard imports** (`from module import *`)
- **Exception**: import inside a function only to resolve circular dependencies
- Use short aliases for frequently used modules: `from myapp import config as cfg`

---

## Error Handling

- Create domain-specific exception hierarchies (`PaymentError` → `InsufficientFundsError`)
- Catch specific exceptions, not bare `except Exception`
- Use context managers for resource management (`@contextmanager`)
- **Do not use exceptions for control flow** — exceptions signal errors, not branching logic
- **No log-and-reraise** — either handle the exception or let it propagate, not both
- **Let exceptions bubble** unless the current layer can meaningfully recover
- **No `assert` in application code** — raise custom errors instead; reserve `assert` for tests only
