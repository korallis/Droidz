# Python Development Standards

## Code Style (PEP 8)

### Type Annotations (Required)

```python
from typing import List, Optional, Dict, Any
from dataclasses import dataclass

# ✅ Good: Type annotations everywhere
def calculate_total(items: List[float], tax_rate: float = 0.1) -> float:
    subtotal = sum(items)
    return subtotal * (1 + tax_rate)

# ✅ Good: Dataclass for data structures
@dataclass
class User:
    id: int
    email: str
    name: str
    is_active: bool = True

# ✅ Good: Optional for nullable values
def get_user(user_id: int) -> Optional[User]:
    user = db.query(User).filter_by(id=user_id).first()
    return user
```

### Modern Python Features

```python
# ✅ Good: Type hints with Python 3.10+ syntax
def process_users(users: list[User]) -> dict[str, Any]:
    return {"count": len(users), "active": sum(u.is_active for u in users)}

# ✅ Good: Match statement (Python 3.10+)
match status:
    case "active":
        return activate_user()
    case "inactive":
        return deactivate_user()
    case _:
        raise ValueError(f"Unknown status: {status}")

# ✅ Good: Structural pattern matching
match response:
    case {"status": 200, "data": data}:
        return process_data(data)
    case {"status": 404}:
        raise NotFoundError()
```

## FastAPI Patterns (if using FastAPI)

```python
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, EmailStr, validator

app = FastAPI()

# ✅ Good: Pydantic models for validation
class UserCreate(BaseModel):
    email: EmailStr
    password: str
    name: str
    
    @validator('password')
    def password_strength(cls, v):
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        return v

# ✅ Good: Dependency injection
def get_current_user(token: str = Depends(oauth2_scheme)) -> User:
    user = verify_token(token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    return user

# ✅ Good: Typed routes
@app.post("/users", response_model=UserResponse)
async def create_user(
    user: UserCreate,
    current_user: User = Depends(get_current_user)
) -> UserResponse:
    db_user = await create_user_in_db(user)
    return UserResponse.from_orm(db_user)
```

## Error Handling

```python
from typing import Union
from result import Result, Ok, Err

# ✅ Good: Result type for explicit error handling
def divide(a: float, b: float) -> Result[float, str]:
    if b == 0:
        return Err("Division by zero")
    return Ok(a / b)

# Usage
result = divide(10, 2)
match result:
    case Ok(value):
        print(f"Result: {value}")
    case Err(error):
        print(f"Error: {error}")

# ✅ Good: Custom exceptions
class UserNotFoundError(Exception):
    """Raised when user cannot be found."""
    
    def __init__(self, user_id: int):
        self.user_id = user_id
        super().__init__(f"User {user_id} not found")

# ✅ Good: Context managers for cleanup
from contextlib import contextmanager

@contextmanager
def database_transaction():
    conn = get_connection()
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()
```

## Testing (pytest)

```python
import pytest
from unittest.mock import Mock, patch

# ✅ Good: Descriptive test names
def test_user_creation_with_valid_data_returns_user():
    user = create_user(email="test@example.com", name="Test User")
    assert user.email == "test@example.com"
    assert user.is_active is True

# ✅ Good: Fixtures for setup
@pytest.fixture
def sample_user():
    return User(id=1, email="test@example.com", name="Test")

def test_user_deactivation(sample_user):
    deactivate_user(sample_user.id)
    user = get_user(sample_user.id)
    assert user.is_active is False

# ✅ Good: Parametrized tests
@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("World", "WORLD"),
    ("", ""),
])
def test_uppercase(input, expected):
    assert uppercase(input) == expected

# ✅ Good: Mocking external dependencies
@patch('app.services.external_api.call')
def test_api_integration(mock_api_call):
    mock_api_call.return_value = {"status": "success"}
    result = fetch_external_data()
    assert result["status"] == "success"
    mock_api_call.assert_called_once()
```

## Async/Await

```python
import asyncio
from typing import List

# ✅ Good: Async functions for I/O-bound operations
async def fetch_user(user_id: int) -> User:
    async with httpx.AsyncClient() as client:
        response = await client.get(f"/users/{user_id}")
        return User(**response.json())

# ✅ Good: Gather for concurrent operations
async def fetch_multiple_users(user_ids: List[int]) -> List[User]:
    tasks = [fetch_user(uid) for uid in user_ids]
    return await asyncio.gather(*tasks)

# ✅ Good: Async context managers
from contextlib import asynccontextmanager

@asynccontextmanager
async def database_session():
    session = await create_session()
    try:
        yield session
        await session.commit()
    except Exception:
        await session.rollback()
        raise
    finally:
        await session.close()
```

## File Structure

```
project/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI app / entry point
│   ├── models/              # Database models
│   │   ├── __init__.py
│   │   └── user.py
│   ├── schemas/             # Pydantic schemas
│   │   ├── __init__.py
│   │   └── user.py
│   ├── routes/              # API routes
│   │   ├── __init__.py
│   │   └── users.py
│   ├── services/            # Business logic
│   │   ├── __init__.py
│   │   └── user_service.py
│   ├── repositories/        # Data access
│   │   ├── __init__.py
│   │   └── user_repository.py
│   └── utils/               # Utilities
│       └── __init__.py
├── tests/
│   ├── test_users.py
│   └── conftest.py          # pytest fixtures
├── requirements.txt
├── pyproject.toml
└── README.md
```

## Code Quality Tools

```toml
# pyproject.toml
[tool.black]
line-length = 100
target-version = ['py311']

[tool.isort]
profile = "black"
line_length = 100

[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = "-v --cov=app --cov-report=term-missing"
```

## Security

```python
from passlib.context import CryptContext
from sqlalchemy import text

# ✅ Good: Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

# ✅ Good: Parameterized queries (prevent SQL injection)
def get_user_by_email(email: str) -> Optional[User]:
    query = text("SELECT * FROM users WHERE email = :email")
    result = db.execute(query, {"email": email})
    return result.first()

# ❌ Bad: String formatting (SQL INJECTION!)
def bad_query(email: str):
    query = f"SELECT * FROM users WHERE email = '{email}'"  # VULNERABLE!
    return db.execute(query)

# ✅ Good: Environment variables for secrets
import os
from pydantic import BaseSettings

class Settings(BaseSettings):
    database_url: str
    secret_key: str
    api_key: str
    
    class Config:
        env_file = ".env"

settings = Settings()
```

## Never

- ❌ Never use `exec()` or `eval()` with user input
- ❌ Never commit API keys or secrets (use environment variables)
- ❌ Never use mutable default arguments (`def func(items=[]):`)
- ❌ Never ignore type hints in Python 3.10+
- ❌ Never use `except:` without specifying exception type
- ❌ Never use `from module import *`
- ❌ Never modify function arguments in place (unless documented)
