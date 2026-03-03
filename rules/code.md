---
paths:
  - "**/*.py"
---

# Developer Guidelines

General Python development best practices and coding standards.

## ⚠️ CRITICAL: KISS & YAGNI ENFORCEMENT

**DO NOT IMPLEMENT ANYTHING BEYOND WHAT IS EXPLICITLY REQUESTED.**

Before implementing anything, verify:
- [ ] Is this explicitly requested, or am I adding scope?
- [ ] Have I used a tool to confirm the answer, or am I guessing?
- [ ] Does this follow the existing pattern in the codebase?

Rules:
- Build ONLY what is asked for - nothing more
- Choose the simplest solution that works
- No speculative features or "nice-to-haves"
- No additional functionality "just in case"
- Stop when the requirement is met

## Core Development Philosophy

### KISS (Keep It Simple, Stupid)

Simplicity should be a key goal in design. Choose straightforward solutions over complex ones whenever possible. Simple solutions are easier to understand, maintain, and debug.

### YAGNI (You Aren't Gonna Need It)

Avoid building functionality on speculation. Implement features only when they are needed, not when you anticipate they might be useful in the future.

### Single Responsibility

Each class and function should have one well-defined responsibility

### DRY (Don't Repeat Yourself)

When adding new features, implement logic in one place and pass parameters through. Avoid duplicating logic across layers - if a lower layer handles the logic, upper layers should just pass parameters through.

### Design Principles

- **Dependency Inversion**: High-level modules should not depend on low-level modules. Both should depend on abstractions.
- **Open/Closed Principle**: Software entities should be open for extension but closed for modification.
- **Single Responsibility**: Each function, class, and module should have one clear purpose.
- **Fail Fast**: Check for potential errors early and raise exceptions immediately when issues occur.

---

## 🧱 Code Structure & Modularity

### File and Function Limits

- **Never create a file longer than 500 lines of code**. If approaching this limit, refactor by splitting into modules.
- **Functions should be under 50 lines** with a single, clear responsibility.
- **Classes should be under 100 lines** and represent a single concept or entity.
- **Organize code into clearly separated modules**, grouped by feature or responsibility.
- **Line length should be max 120 characters** ruff rule in pyproject.toml

## 📋 Style & Conventions

### Python Style Guide

- **Follow PEP8** with these specific choices:
  - Line length: 120 characters
  - Use double quotes for strings
  - Use trailing commas in multi-line structures
- **Always use type hints** for function signatures and class attributes
- **Format with `make lint`**
- **Use `pydantic` v2** for data validation and settings management

#### Function Calls

**Pass kwargs as keyword arguments:** Always use keyword arguments when passing optional parameters, not positional arguments. This improves code clarity and maintainability.

### Commenting Best Practices

**DO NOT comment obvious code.** Good naming and type hints should make most code self-explanatory.

```python
# ❌ BAD: Obvious comment
# Get the user's name
name = user.name

# ✅ GOOD: Comment explains WHY, not WHAT
# Reason: Bulk discount per business rule #347
if quantity > 100:
    return base_price * Decimal("0.9") * quantity
```

Only add comments to explain:
- Business rules or domain logic
- Workarounds or non-obvious decisions
- Important side effects or caveats

### Documentation Best Practices

Documentation should be **timeless and high-level**, focusing on architecture and patterns rather than implementation details.

**Principles:**

1. **No Code Examples in Architecture Docs** - Code changes frequently, making examples outdated
   - ✅ GOOD: "Scrapers use `prepare_download_directory()` for overwrite handling"
   - ❌ BAD: Including the full function implementation in `CLAUDE.md`

2. **Avoid Volatile Details** - Magic numbers and specifics that frequently change
   - ✅ GOOD: "OpenAI Vision API"
   - ❌ BAD: "OpenAI GPT-5-mini Vision API" or "10 scrapers" or "version 3.2.1"
   - **Examples of volatile details**: Model names, file counts, version numbers, specific URLs
   - **Rationale**: These change frequently, breaking documentation accuracy

**Remember**: Outdated documentation is worse than no documentation. Keep docs high-level, architectural, and resistant to code changes.

### Naming Conventions

- **Variables and functions**: `snake_case`
- **Classes**: `PascalCase`
- **Constants**: `UPPER_SNAKE_CASE`
- **Private attributes/methods**: `_leading_underscore`
- **Type aliases**: `PascalCase`
- **Enum values**: `UPPER_SNAKE_CASE`

### Configuration Extraction

**Extract magic values to a config module** instead of hardcoding in functions:

```python
# ✅ GOOD: Config module with prefixed constants
# config.py
API_MODEL = "gpt-4.1-mini"
API_TIMEOUT = 90

# usage.py
from src.config import settings
response = client.call(model=settings.API_MODEL, timeout=settings.API_TIMEOUT)

# ❌ BAD: Hardcoded values in functions
response = client.call(model="gpt-4.1-mini", timeout=90)
```

### Import Conventions

**Always place imports at the top of the file.** Only import within functions when resolving circular dependencies.

**Use short aliases for frequently used config modules:**
```python
from myapp import config as cfg
```

```python
# ✅ CORRECT: Imports at the top
from datetime import datetime


def process_data(timestamp: str) -> None:
    """Process data with dependencies available."""
    # ...


# ❌ INCORRECT: Imports inside functions (unless resolving circular dependency)
def process_data(timestamp: str) -> None:
    """Avoid this pattern unless necessary for circular imports."""
    from datetime import datetime  # Don't do this
    # ...
```

## 🚨 Error Handling

### Exception Best Practices

```python
# Create custom exceptions for your domain
class PaymentError(Exception):
    """Base exception for payment-related errors."""
    pass

class InsufficientFundsError(PaymentError):
    """Raised when account has insufficient funds."""
    def __init__(self, required: Decimal, available: Decimal):
        self.required = required
        self.available = available
        super().__init__(
            f"Insufficient funds: required {required}, available {available}"
        )

# Use specific exception handling
try:
    process_payment(amount)
except InsufficientFundsError as e:
    logger.warning(f"Payment failed: {e}")
    return PaymentResult(success=False, reason="insufficient_funds")
except PaymentError as e:
    logger.error(f"Payment error: {e}")
    return PaymentResult(success=False, reason="payment_error")

# Use context managers for resource management
from contextlib import contextmanager

@contextmanager
def database_transaction():
    """Provide a transactional scope for database operations."""
    conn = get_connection()
    trans = conn.begin_transaction()
    try:
        yield conn
        trans.commit()
    except Exception:
        trans.rollback()
        raise
    finally:
        conn.close()
```

### Logging Strategy

```python
import logging
from functools import wraps

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

# Log function entry/exit for debugging
def log_execution(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        logger.debug(f"Entering {func.__name__}")
        try:
            result = func(*args, **kwargs)
            logger.debug(f"Exiting {func.__name__} successfully")
            return result
        except Exception as e:
            logger.exception(f"Error in {func.__name__}: {e.__class__.__name__}: {e}")
            raise
    return wrapper
```

## 🔧 Configuration Management

### Environment Variables and Settings

```python
from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    """Application settings with validation."""
    APP_NAME: str = "MyApp"
    DEBUG: bool = False
    DATABASE_URL: str
    REDIS_URL: str = "redis://localhost:6379"
    API_KEY: str
    MAX_CONNECTIONS: int = 100

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False

@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()

# Usage
settings = get_settings()
```

## 🏗️ Data Models and Validation

### Example Pydantic Models strict with pydantic v2

```python
from pydantic import BaseModel, Field, field_validator, EmailStr
from datetime import datetime
from decimal import Decimal

class ProductBase(BaseModel):
    """Base product model with common fields."""
    name: str = Field(..., min_length=1, max_length=255)
    description: str | None = None
    price: Decimal = Field(..., gt=0, decimal_places=2)
    category: str
    tags: list[str] = []

    @field_validator("price")
    @classmethod
    def validate_price(cls, v: Decimal) -> Decimal:
        if v > Decimal("1000000"):
            raise ValueError("Price cannot exceed 1,000,000")
        return v

    class Config:
        json_encoders = {
            Decimal: str,
            datetime: lambda v: v.isoformat()
        }

class ProductCreate(ProductBase):
    """Model for creating new products."""
    pass

class ProductUpdate(BaseModel):
    """Model for updating products - all fields optional."""
    name: str | None = Field(None, min_length=1, max_length=255)
    description: str | None = None
    price: Decimal | None = Field(None, gt=0, decimal_places=2)
    category: str | None = None
    tags: list[str] | None = None

class Product(ProductBase):
    """Complete product model with database fields."""
    id: int
    created_at: datetime
    updated_at: datetime
    is_active: bool = True

    class Config:
        from_attributes = True  # Enable ORM mode
```



## 🚀 Performance Considerations

### Optimization Guidelines

- Profile before optimizing - use `cProfile` or `py-spy`
- Use `lru_cache` for expensive computations
- Prefer generators for large datasets
- Use `asyncio` for I/O-bound operations
- Consider `multiprocessing` for CPU-bound tasks
- Cache database queries appropriately

### Example Optimization

```python
from functools import lru_cache
import asyncio
from typing import AsyncIterator

@lru_cache(maxsize=1000)
def expensive_calculation(n: int) -> int:
    """Cache results of expensive calculations."""
    # Complex computation here
    return result

async def process_large_dataset() -> AsyncIterator[dict]:
    """Process large dataset without loading all into memory."""
    async with aiofiles.open("large_file.json", mode="r") as f:
        async for line in f:
            data = json.loads(line)
            # Process and yield each item
            yield process_item(data)
```

## 🛡️ Security Best Practices

### Security Guidelines

- Never commit secrets - use environment variables
- Validate all user input with Pydantic
- Use parameterized queries for database operations
- Implement rate limiting for APIs
- Use HTTPS for all external communications
- Implement proper authentication and authorization

### Example Security Implementation

```python
from passlib.context import CryptContext
import secrets

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    """Hash password using bcrypt."""
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against its hash."""
    return pwd_context.verify(plain_password, hashed_password)

def generate_secure_token(length: int = 32) -> str:
    """Generate a cryptographically secure random token."""
    return secrets.token_urlsafe(length)
```

## 📊 Monitoring and Observability

### Structured Logging

```python
import structlog

logger = structlog.get_logger()

# Log with context
logger.info(
    "payment_processed",
    user_id=user.id,
    amount=amount,
    currency="USD",
    processing_time=processing_time
)
```

## 📚 Useful Resources

### Essential Tools

- Pytest: https://docs.pytest.org/
- Pydantic: https://docs.pydantic.dev/
- FastAPI: https://fastapi.tiangolo.com/

### Python Best Practices

- PEP 8: https://pep8.org/
- PEP 484 (Type Hints): https://www.python.org/dev/peps/pep-0484/
- The Hitchhiker's Guide to Python: https://docs.python-guide.org/
