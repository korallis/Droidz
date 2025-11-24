---
name: test-driven-development
description: Implement test-driven development (TDD) workflow using the red-green-refactor cycle. Use when writing new features, fixing bugs, or refactoring existing code. Always write the failing test first, then implement minimal code to pass, then refactor. Use when writing new features, fixing bugs, refactoring existing code, or adding test coverage. Essential for ensuring code reliability before implementation.
---

# Test-Driven Development (TDD)

Implement the red-green-refactor cycle for reliable, testable code.

## When to use this skill

- Writing new features or functionality
- Fixing bugs with regression tests
- Refactoring existing code safely
- Adding test coverage to untested code
- Ensuring code behaves as expected

## TDD Cycle

### 1. RED - Write a Failing Test

Write a test that describes the desired behavior BEFORE implementing:

```python
def test_user_can_register():
    """Test that a user can successfully register with valid data."""
    result = register_user(email="test@example.com", password="secure123")
    assert result.success is True
    assert result.user.email == "test@example.com"
```

**Why this works:**
- Forces clear requirements thinking
- Catches specification issues early
- Provides immediate feedback on implementation
- Creates living documentation

### 2. GREEN - Write Minimal Code to Pass

Implement ONLY what's needed to make the test pass:

```python
def register_user(email: str, password: str) -> RegistrationResult:
    """Register a new user with email and password."""
    user = User(email=email)
    return RegistrationResult(success=True, user=user)
```

**Resist the urge to:**
- Add features not covered by tests
- Over-engineer the solution
- Optimize prematurely

### 3. REFACTOR - Improve Code Quality

With tests passing, improve the code structure:

```python
def register_user(email: str, password: str) -> RegistrationResult:
    """Register a new user with email and password."""
    validate_email(email)
    validate_password(password)
    
    hashed_password = hash_password(password)
    user = User(email=email, password_hash=hashed_password)
    user.save()
    
    return RegistrationResult(success=True, user=user)
```

**Refactor for:**
- Better naming
- Removed duplication
- Improved structure
- Enhanced readability

## Best Practices

### Start with the Simplest Test

```python
# Good - Start simple
def test_add_returns_sum():
    assert add(2, 3) == 5

# Avoid - Don't start with edge cases
def test_add_handles_overflow_with_large_numbers():
    assert add(sys.maxsize, 1) == expected_overflow_behavior
```

### Test One Thing at a Time

```python
# Good - Single concern
def test_user_registration_creates_user():
    result = register_user("test@example.com", "pass123")
    assert result.user is not None

def test_user_registration_hashes_password():
    result = register_user("test@example.com", "pass123")
    assert result.user.password_hash != "pass123"

# Avoid - Multiple assertions
def test_user_registration():
    result = register_user("test@example.com", "pass123")
    assert result.user is not None
    assert result.user.password_hash != "pass123"
    assert result.user.email == "test@example.com"
    assert result.success is True
```

### Use Descriptive Test Names

```python
# Good - Describes behavior
def test_invalid_email_returns_validation_error()
def test_duplicate_email_raises_already_exists_error()
def test_successful_registration_sends_welcome_email()

# Avoid - Vague names
def test_register()
def test_email()
def test_validation()
```

### Follow the Three A's Pattern

```python
def test_user_can_update_profile():
    # Arrange - Set up test data
    user = create_test_user(email="test@example.com")
    
    # Act - Execute the operation
    result = user.update_profile(name="John Doe", bio="Developer")
    
    # Assert - Verify the outcome
    assert result.success is True
    assert user.name == "John Doe"
    assert user.bio == "Developer"
```

## Common Patterns

### Testing Exceptions

```python
def test_registration_with_invalid_email_raises_error():
    with pytest.raises(ValidationError) as exc:
        register_user(email="invalid", password="pass123")
    
    assert "valid email" in str(exc.value)
```

### Testing Async Code

```python
@pytest.mark.asyncio
async def test_async_user_registration():
    result = await register_user_async("test@example.com", "pass123")
    assert result.success is True
```

### Using Fixtures

```python
@pytest.fixture
def test_user():
    return User(email="test@example.com", name="Test User")

def test_user_can_login(test_user):
    result = login(test_user.email, "correct_password")
    assert result.success is True
```

### Mocking External Dependencies

```python
def test_user_registration_sends_email(mocker):
    # Mock the email service
    mock_send = mocker.patch('services.email.send_welcome_email')
    
    register_user("test@example.com", "pass123")
    
    # Verify email was sent
    mock_send.assert_called_once_with("test@example.com")
```

## Verification Checklist

Before completing TDD implementation:

- [ ] Test written BEFORE implementation
- [ ] Test fails initially (RED phase confirmed)
- [ ] Minimal code added to pass test (GREEN phase)
- [ ] Code refactored while keeping tests green
- [ ] Test names clearly describe behavior
- [ ] Each test focuses on one behavior
- [ ] No untested code paths remain
- [ ] All tests pass consistently
- [ ] Code is readable and maintainable

## Benefits of TDD

1. **Better Design** - Writing tests first leads to more modular, testable code
2. **Confidence** - Comprehensive test suite catches regressions
3. **Documentation** - Tests serve as living documentation
4. **Faster Debugging** - Failures pinpoint exact issues
5. **Reduced Bugs** - Edge cases caught during development

## When NOT to Use Strict TDD

- Rapid prototyping/proof of concepts
- UI layout experimentation
- Exploratory coding (learning new APIs)
- Trivial getter/setter methods

For these cases, write tests after implementation but before committing.

## Integration with Development Workflow

```bash
# TDD development loop
git checkout -b feature/user-registration

# 1. Write failing test
# 2. Run tests (should fail)
pytest tests/test_registration.py

# 3. Implement minimal code
# 4. Run tests (should pass)
pytest tests/test_registration.py

# 5. Refactor
# 6. Run tests (should still pass)
pytest tests/test_registration.py

# Commit when all tests pass
git add .
git commit -m "feat: implement user registration with TDD"
```

## References

- Kent Beck - "Test-Driven Development: By Example"
- Martin Fowler - "Refactoring: Improving the Design of Existing Code"
- [pytest documentation](https://docs.pytest.org/)
- [unittest documentation](https://docs.python.org/3/library/unittest.html)
