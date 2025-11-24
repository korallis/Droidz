# Error Handling

## Overview

Proper error handling is critical for application reliability, user experience, and debugging. This standard defines how to handle errors consistently across the codebase.

## When to Apply

- All functions that can fail
- External API calls and database operations
- File I/O and network operations
- User input validation
- Async operations and promises

## Core Principles

1. **Fail Fast** - Validate early and throw errors immediately when detecting invalid state
2. **Be Specific** - Use specific error types/classes for different failure scenarios
3. **Provide Context** - Include relevant information in error messages for debugging
4. **User-Friendly** - Show helpful messages to users without exposing internals
5. **Centralized Handling** - Handle errors at appropriate boundaries (API layer, UI layer)

## ✅ DO

### DO: Use Specific Error Types

**✅ DO**:
```typescript
class ValidationError extends Error {
  constructor(message: string, public field: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

class NotFoundError extends Error {
  constructor(resource: string, id: string) {
    super(`${resource} with id ${id} not found`);
    this.name = 'NotFoundError';
  }
}

throw new ValidationError('Email is required', 'email');
```

### DO: Provide Context in Errors

**✅ DO**:
```typescript
try {
  await fetchUser(userId);
} catch (error) {
  throw new Error(`Failed to fetch user ${userId}: ${error.message}`, {
    cause: error
  });
}
```

### DO: Handle Errors at Boundaries

**✅ DO**:
```typescript
// API route handler
app.post('/api/users', async (req, res) => {
  try {
    const user = await createUser(req.body);
    res.json(user);
  } catch (error) {
    if (error instanceof ValidationError) {
      return res.status(400).json({ error: error.message, field: error.field });
    }
    if (error instanceof NotFoundError) {
      return res.status(404).json({ error: error.message });
    }
    // Generic error
    console.error('Unexpected error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});
```

### DO: Clean Up Resources

**✅ DO**:
```typescript
async function processFile(filePath: string) {
  const file = await fs.open(filePath);
  try {
    const data = await file.read();
    return processData(data);
  } finally {
    await file.close(); // Always clean up
  }
}
```

### DO: Use Retry Logic for Transient Failures

**✅ DO**:
```typescript
async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3
): Promise<T> {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, Math.pow(2, i) * 1000));
    }
  }
  throw new Error('Max retries exceeded');
}

// Usage
const data = await retryWithBackoff(() => fetchFromAPI(url));
```

## ❌ DON'T

### DON'T: Swallow Errors Silently

**❌ DON'T**:
```typescript
try {
  await saveData(data);
} catch (error) {
  // Silent failure - data not saved but no indication!
}
```
**Why**: Hides failures and makes debugging impossible.

### DON'T: Use Generic Error Types

**❌ DON'T**:
```typescript
throw new Error('Something went wrong');
throw new Error('Error');
```
**Why**: Doesn't provide enough context for debugging or handling.

### DON'T: Expose Internal Details to Users

**❌ DON'T**:
```typescript
catch (error) {
  res.status(500).json({
    error: error.stack, // Exposes internals!
    query: sqlQuery     // Security risk!
  });
}
```
**Why**: Security risk and poor UX.

### DON'T: Catch Without Re-throwing

**❌ DON'T**:
```typescript
async function fetchData() {
  try {
    return await api.getData();
  } catch (error) {
    console.log('Error fetching data');
    return null; // Caller doesn't know it failed!
  }
}
```
**Why**: Caller can't distinguish between "no data" and "error".

### DON'T: Create Error Handling Pyramids

**❌ DON'T**:
```typescript
try {
  const user = await getUser();
  try {
    const posts = await getPosts(user.id);
    try {
      const comments = await getComments(posts);
      // Nested hell
    } catch (e3) { }
  } catch (e2) { }
} catch (e1) { }
```
**Why**: Hard to read and maintain. Use async/await properly.

## Patterns & Examples

### Pattern 1: Error Boundary Component (React)

**Use Case**: Catch errors in React component tree

**Implementation**:
```typescript
class ErrorBoundary extends React.Component {
  state = { hasError: false, error: null };
  
  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }
  
  componentDidCatch(error, errorInfo) {
    // Log to error reporting service
    console.error('Error caught:', error, errorInfo);
  }
  
  render() {
    if (this.state.hasError) {
      return <ErrorFallback error={this.state.error} />;
    }
    return this.props.children;
  }
}
```

### Pattern 2: Result Type (Functional Approach)

**Use Case**: Avoid throwing exceptions for expected failures

**Implementation**:
```typescript
type Result<T, E = Error> = 
  | { ok: true; value: T }
  | { ok: false; error: E };

function divide(a: number, b: number): Result<number> {
  if (b === 0) {
    return { ok: false, error: new Error('Division by zero') };
  }
  return { ok: true, value: a / b };
}

// Usage
const result = divide(10, 2);
if (result.ok) {
  console.log(result.value);
} else {
  console.error(result.error);
}
```

### Pattern 3: Graceful Degradation

**Use Case**: Continue operation when non-critical services fail

**Implementation**:
```typescript
async function getUserWithRecommendations(userId: string) {
  const user = await getUser(userId); // Critical - throw if fails
  
  let recommendations = [];
  try {
    recommendations = await getRecommendations(userId); // Non-critical
  } catch (error) {
    console.warn('Failed to load recommendations:', error);
    // Continue without recommendations
  }
  
  return { user, recommendations };
}
```

## Common Mistakes

1. **Catching Too Broadly**
   - Problem: `catch(error)` catches everything including typos
   - Solution: Catch specific error types or let unexpected errors bubble

2. **Not Validating Input Early**
   - Problem: Errors occur deep in call stack
   - Solution: Validate at entry points (API routes, function start)

3. **Logging Then Re-throwing Without Adding Context**
   - Problem: Duplicate logs without useful information
   - Solution: Add context when re-throwing or log once at boundary

4. **Using Errors for Control Flow**
   - Problem: `try-catch` for non-exceptional cases
   - Solution: Use conditionals for expected cases, errors for exceptional ones

## Testing Standards

```typescript
describe('Error Handling', () => {
  it('should throw ValidationError for invalid input', () => {
    expect(() => createUser({ email: '' }))
      .toThrow(ValidationError);
  });
  
  it('should include field name in validation error', () => {
    try {
      createUser({ email: '' });
    } catch (error) {
      expect(error).toBeInstanceOf(ValidationError);
      expect(error.field).toBe('email');
    }
  });
  
  it('should retry on transient failures', async () => {
    const mock = jest.fn()
      .mockRejectedValueOnce(new Error('Transient'))
      .mockResolvedValueOnce('success');
    
    const result = await retryWithBackoff(mock);
    expect(result).toBe('success');
    expect(mock).toHaveBeenCalledTimes(2);
  });
});
```

## Resources

- [MDN: Error](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error)
- [Node.js Error Handling Best Practices](https://nodejs.org/en/docs/guides/error-handling/)
- [TypeScript: Error Handling](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#using-type-predicates)
- [Rust Book: Error Handling](https://doc.rust-lang.org/book/ch09-00-error-handling.html) (excellent functional patterns)
