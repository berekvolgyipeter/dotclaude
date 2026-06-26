# Python Developer Rules

## Core Development Philosophy

- **KISS**: Choose the simplest solution that works. Before implementing, confirm the request is explicit and use tools to verify rather than guessing.
- **YAGNI**: Build only what is explicitly requested — no speculative features, no "just in case" additions. Stop when the requirement is met.
- **DRY**: Implement logic once; upper layers pass parameters through, not re-implement.
- **Fail Fast**: Raise exceptions immediately when issues occur.
- **Be Explicit About Mutation**: If a function mutates a caller-owned argument (list, dict, set) as part of its contract, make it obvious — through the name (`append_*`, `update_*`, `populate_*`), a clear parameter name (`out`, `buffer`, `accumulator`), or a brief docstring note. Do not silently mutate arguments as an incidental side effect. Do **not** defensively `copy`/`deepcopy` inputs just to avoid mutation — trust the caller and prefer returning new values only when it's natural (e.g. pure transforms). In-place operations on locally constructed objects are always fine.
- **Dependency Inversion**: Depend on abstractions for service/module dependencies — not for configuration (see Configuration Extraction below).

---

## Code Structure & Modularity

- **Max file length: 500 lines** — split into modules when approaching this limit
- **Max function length: 50 lines**
- **Max class length: 200 lines**
- **Max cyclomatic complexity: 3** — flatten deep nesting with early returns, guard clauses, or extracted helpers
- **Max function arguments: 4** — if a function needs more, apply one of these in order of preference:
  1. **Introduce a dataclass** — group related parameters into a named object
  2. **Promote to class state** — if the same args recur across methods, make them `__init__` parameters
  3. **Decompose the function** — if parameters belong to distinct concerns, split into smaller functions

```python
# ❌ BAD — too many arguments
def publish_document(doc: Doc, threshold: int, retries: int, timeout: float, mode: str, dry_run: bool): ...

# ✅ GOOD — grouped into a dataclass
@dataclass
class PublishConfig:
    threshold: int
    retries: int
    timeout: float
    mode: str
    dry_run: bool

def publish_document(doc: Doc, config: PublishConfig): ...
```

- Organize code into clearly separated modules grouped by feature or responsibility

- **Single Level of Abstraction per method** — every statement in a method should operate at the same abstraction level. Extract low-level steps into private methods so the parent reads as a clean sequence of same-level operations.

```python
# ❌ BAD — mixed abstraction levels
async def fulfill_order(self, order: Order) -> Receipt:
    try:
        items = await asyncio.gather(*[fetch_item(i) for i in order.item_ids])
    except Exception as e:
        logger.warning(f"Failed to fetch items: {e}")
        return Receipt(status="failed")

    total = sum(i.price for i in items)
    if total > self.limit:
        return Receipt(status="over_limit")

    return await self.payment_gateway.charge(order.account, total)

# ✅ GOOD — each step at the same level
async def fulfill_order(self, order: Order) -> Receipt:
    items = await self._fetch_items(order)
    if items is None:
        return Receipt(status="failed")

    return await self._charge_account(order, items)
```

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
- **Format with the project's lint command** (e.g. `make lint`)
- **Use `pydantic` v2** for data validation and settings management
- **Always use keyword arguments** for optional parameters, not positional
- **f-strings only** — never `%` formatting or `.format()`
- **`pathlib` over `os.path`** for all file/path operations
- **`@property` not getter/setter methods** — `user.name`, not `user.get_name()`

### Naming — The 5-Second Rule

**If you can't understand what a function, class, or variable does within 5 seconds of reading its name, the name is wrong.**

- **No vague names** — every name must reveal intent
- **No abbreviations** — `user_repository.py` not `usr_repo.py`
- **Name length proportional to scope** — `i` is acceptable in a 3-line loop; module-level names need full descriptive words
- **Functions**: use **verb + domain + detail** — describe the action being performed. If you need "and" to describe what a function does, split it
- **Classes**: name by **responsibility**, not data shape — what it *does*, not what it *holds*
- **Variables**: name by **meaning in context**, not type or structure. **Always include the noun** — never name a variable with only an adjective or past participle (`updated`, `discovered`, `extracted`, `filtered`). The name must answer "updated *what*?". Prefer the bare noun when the scope is clear (`orders`); only qualify it (`updated_orders`) when the unqualified name is already taken or genuinely ambiguous in context
- **Booleans**: must use an intent-revealing prefix — `is_`, `has_`, `does_`, `can_`, `should_`. Applies to both variables and methods that return `bool`
- **One concept, one name everywhere** — pick a single term for a concept and use it consistently across every name that refers to it: variables, parameters, functions, attributes, types, files. The same thing should not be `email` in one place and `mail` in another, or `fetch_*` here and `get_*` there. When you rename, propagate it to every occurrence in one pass so no synonym lingers.
- **No ambiguous names** — a name must resolve to exactly one thing in its context. When a bare term could refer to more than one entity — e.g. an `id`/`uuid`/`name` field that could be the object's own *or* a referenced entity's — qualify it with its owner (`owner_id`, `parent_uuid`), and reserve the bare term for the thing's own identity.

```python
# ❌ BAD — vague, requires reading the body to understand
def process(data): ...
def handle(event): ...
def do_stuff(items): ...
class Manager: ...
class Info: ...
temp = get_result()
updated = update_orders(orders)        # updated what? potatoes?
discovered = scan_directory(path)      # discovered what?

# ✅ GOOD — intent is obvious from the name alone
def validate_user_email(email: str) -> bool: ...
def fetch_active_subscriptions(user_id: str) -> list[Subscription]: ...
def transform_api_response(raw: dict) -> OrderSummary: ...
class PaymentGatewayClient: ...
class InventoryAllocationService: ...
active_subscription_count = count_active_subscriptions(user)
orders = update_orders(orders)                       # bare noun when scope is clear
updated_orders = update_orders(orders)               # qualify only when `orders` is taken
files = scan_directory(path)
```

### Models and Dataclasses

- **Define models in dedicated modules** (`models/`, `schemas/`), never inline with business logic
- **Prefer dataclasses over complex nested return types** — use a named dataclass instead of `tuple[int, list[tuple[str, int]]]`
- **Pydantic models** for validation boundaries (API input/output, config, external data). **Dataclasses** for internal domain objects with no validation needs

### Enums

- **Use `StrEnum`/`IntEnum` for categorical values** — no magic strings scattered through code
- **Define enums close to their domain** — in the relevant `models/` or `enums.py` module

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
def dispatch_pending_orders():
    threshold = settings.ORDER_THRESHOLD
    ...

# Pure/utility — takes parameters, no config dependency
def filter_orders(orders: list[Order], threshold: int) -> list[Order]:
    ...
```

### Comments

- **Default to no comments** — well-named identifiers and types document *what*. Only comment when the *why* is non-obvious (hidden constraint, subtle invariant, workaround for a specific bug)
- **Never restate the code** — if the comment paraphrases the next line, delete it
- **No task/PR context** — don't reference the current change, ticket, or callers; that belongs in commit messages
- **One line is almost always enough** — never write multi-paragraph comment blocks
- **Docstrings**: write one only when the contract is non-obvious from the signature. Single line unless behavior is genuinely complex. Don't restate parameter types or echo the function name in prose

### Imports

- Always at the top of the file, ordered: stdlib → third-party → local
- **Use absolute imports** — never relative (`from ..utils import x`)
- **No wildcard imports** (`from module import *`)
- **Exception**: import inside a function only to resolve circular dependencies

---

## Error Handling

- Create domain-specific exception hierarchies (`PaymentError` → `InsufficientFundsError`)
- Catch specific exceptions, not bare `except Exception`
- **Do not use exceptions for control flow** — exceptions signal errors, not branching logic
- **No log-and-reraise** — either handle the exception or let it propagate, not both
- **Let exceptions bubble** unless the current layer can meaningfully recover
- **No `assert` in application code** — raise custom errors instead; reserve `assert` for tests only
