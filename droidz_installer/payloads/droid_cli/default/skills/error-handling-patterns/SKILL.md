---
name: error-handling-patterns
description: Implementing error handling, designing fault-tolerant systems, debugging production issues, or improving error messages.
---

# Error Handling Patterns - Robust Error Management

**Use when**: Implementing error handling, designing fault-tolerant systems, debugging production issues, or improving error messages.

## Core Principles

1. **Fail Fast, Fail Loud** - Detect errors early, make them visible
2. **Never Swallow Errors** - Always log or handle appropriately
3. **Actionable Error Messages** - Tell users what went wrong and how to fix it
4. **Type-Safe Errors** - Use custom error classes
5. **Graceful Degradation** - System remains functional despite errors

## Error Types

### 1. **Custom Error Classes**

```typescript
// ✅ Base error class
export class AppError extends Error {
  constructor(
    message: string,
    public statusCode: number = 500,
    public code: string = 'INTERNAL_ERROR',
    public isOperational: boolean = true
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

// ✅ Specific error types
export class ValidationError extends AppError {
  constructor(message: string, public fields?: Record<string, string>) {
    super(message, 400, 'VALIDATION_ERROR');
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(`${resource} with id ${id} not found`, 404, 'NOT_FOUND');
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string = 'Authentication required') {
    super(message, 401, 'UNAUTHORIZED');
  }
}

export class ForbiddenError extends AppError {
  constructor(message: string = 'Insufficient permissions') {
    super(message, 403, 'FORBIDDEN');
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super(message, 409, 'CONFLICT');
  }
}

export class RateLimitError extends AppError {
  constructor(public retryAfter: number) {
    super(`Rate limit exceeded. Retry after ${retryAfter} seconds`, 429, 'RATE_LIMIT');
  }
}

// Usage
throw new ValidationError('Invalid email format', {
  email: 'Must be valid email address'
});

throw new NotFoundError('User', userId);

throw new ConflictError('Email already exists');
```

### 2. **Result Type Pattern**

```typescript
// ✅ Type-safe error handling (no exceptions)
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

function divide(a: number, b: number): Result<number> {
  if (b === 0) {
    return {
      success: false,
      error: new Error('Division by zero')
    };
  }
  
  return {
    success: true,
    data: a / b
  };
}

// Usage
const result = divide(10, 2);

if (result.success) {
  console.log(result.data); // TypeScript knows data exists
} else {
  console.error(result.error); // TypeScript knows error exists
}

// ✅ Async version
async function fetchUser(id: string): Promise<Result<User>> {
  try {
    const user = await db.users.findById(id);
    if (!user) {
      return {
        success: false,
        error: new NotFoundError('User', id)
      };
    }
    return { success: true, data: user };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error : new Error('Unknown error')
    };
  }
}
```

## Express Error Handling

### 1. **Centralized Error Handler**

```typescript
// ✅ Global error middleware
import { Request, Response, NextFunction } from 'express';

export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) {
  // Log error
  console.error({
    error: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
    body: req.body,
    user: req.user?.id
  });

  // Send to error tracking service
  if (process.env.NODE_ENV === 'production') {
    Sentry.captureException(err);
  }

  // Handle custom app errors
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      error: {
        code: err.code,
        message: err.message,
        ...(err instanceof ValidationError && { fields: err.fields })
      }
    });
  }

  // Handle database errors
  if (err.name === 'PrismaClientKnownRequestError') {
    if (err.code === 'P2002') {
      return res.status(409).json({
        error: {
          code: 'DUPLICATE_ENTRY',
          message: 'Resource already exists'
        }
      });
    }
  }

  // Default to 500 for unknown errors
  res.status(500).json({
    error: {
      code: 'INTERNAL_ERROR',
      message: process.env.NODE_ENV === 'production'
        ? 'An unexpected error occurred'
        : err.message
    }
  });
}

// Apply to Express app
app.use(errorHandler);
```

### 2. **Async Error Wrapper**

```typescript
// ✅ Wrapper to catch async errors
function asyncHandler(fn: Function) {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

// Usage - no try/catch needed!
app.get('/users/:id', asyncHandler(async (req, res) => {
  const user = await userService.getUser(req.params.id);
  
  if (!user) {
    throw new NotFoundError('User', req.params.id);
  }
  
  res.json(user);
}));

// Or use express-async-errors package
import 'express-async-errors';

// Now async errors automatically caught
app.get('/users/:id', async (req, res) => {
  const user = await userService.getUser(req.params.id);
  if (!user) {
    throw new NotFoundError('User', req.params.id);
  }
  res.json(user);
});
```

## React Error Handling

### 1. **Error Boundaries**

```typescript
// ✅ Error boundary component
import React, { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: (error: Error) => ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
  state: State = {
    hasError: false,
    error: null
  };

  static getDerivedStateFromError(error: Error): State {
    return {
      hasError: true,
      error
    };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error boundary caught:', error, errorInfo);
    
    // Send to error tracking
    Sentry.captureException(error, {
      contexts: {
        react: {
          componentStack: errorInfo.componentStack
        }
      }
    });
  }

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback(this.state.error!);
      }
      
      return (
        <div className="error-container">
          <h1>Something went wrong</h1>
          <p>{this.state.error?.message}</p>
          <button onClick={() => this.setState({ hasError: false, error: null })}>
            Try again
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}

// Usage
function App() {
  return (
    <ErrorBoundary fallback={(error) => <ErrorPage error={error} />}>
      <MyComponent />
    </ErrorBoundary>
  );
}
```

### 2. **Async Error Handling**

```typescript
// ✅ Handle async errors in components
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);
  const [error, setError] = useState<Error | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchUser() {
      try {
        setLoading(true);
        setError(null);
        const response = await fetch(`/api/users/${userId}`);
        
        if (!response.ok) {
          throw new Error(`Failed to fetch user: ${response.statusText}`);
        }
        
        const data = await response.json();
        setUser(data);
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Unknown error'));
      } finally {
        setLoading(false);
      }
    }

    fetchUser();
  }, [userId]);

  if (loading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!user) return <NotFound />;

  return <div>{user.name}</div>;
}

// ✅ Or use React Query for better error handling
import { useQuery } from '@tanstack/react-query';

function UserProfile({ userId }: { userId: string }) {
  const { data: user, isLoading, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
    retry: 3,
    retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000)
  });

  if (isLoading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!user) return <NotFound />;

  return <div>{user.name}</div>;
}
```

## Retry Strategies

### 1. **Exponential Backoff**

```typescript
// ✅ Retry with exponential backoff
async function fetchWithRetry<T>(
  fn: () => Promise<T>,
  options: {
    maxRetries?: number;
    baseDelay?: number;
    maxDelay?: number;
  } = {}
): Promise<T> {
  const {
    maxRetries = 3,
    baseDelay = 1000,
    maxDelay = 30000
  } = options;

  let lastError: Error;

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error instanceof Error ? error : new Error('Unknown error');
      
      // Don't retry on last attempt
      if (attempt === maxRetries) {
        break;
      }
      
      // Calculate delay with exponential backoff
      const delay = Math.min(baseDelay * Math.pow(2, attempt), maxDelay);
      
      console.log(`Attempt ${attempt + 1} failed, retrying in ${delay}ms...`);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }

  throw lastError!;
}

// Usage
const user = await fetchWithRetry(() => fetch('/api/user').then(r => r.json()), {
  maxRetries: 3,
  baseDelay: 1000
});
```

### 2. **Circuit Breaker**

```typescript
// ✅ Circuit breaker pattern
class CircuitBreaker {
  private failureCount = 0;
  private successCount = 0;
  private nextAttempt = Date.now();
  private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED';

  constructor(
    private threshold: number = 5,
    private timeout: number = 60000,
    private monitoringPeriod: number = 120000
  ) {}

  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'OPEN') {
      if (Date.now() < this.nextAttempt) {
        throw new Error('Circuit breaker is OPEN');
      }
      this.state = 'HALF_OPEN';
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  private onSuccess() {
    this.failureCount = 0;
    
    if (this.state === 'HALF_OPEN') {
      this.state = 'CLOSED';
      this.successCount = 0;
    }
  }

  private onFailure() {
    this.failureCount++;
    this.successCount = 0;

    if (this.failureCount >= this.threshold) {
      this.state = 'OPEN';
      this.nextAttempt = Date.now() + this.timeout;
      console.error('Circuit breaker opened due to failures');
    }
  }
}

// Usage
const breaker = new CircuitBreaker(5, 60000);

try {
  const data = await breaker.execute(() => fetch('/api/unstable-service'));
} catch (error) {
  console.error('Service unavailable');
}
```

## Error Monitoring

### 1. **Sentry Integration**

```typescript
// ✅ Sentry setup
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 1.0,
  beforeSend(event, hint) {
    // Filter sensitive data
    if (event.request) {
      delete event.request.cookies;
      delete event.request.headers?.authorization;
    }
    return event;
  }
});

// Add context to errors
Sentry.setUser({
  id: user.id,
  email: user.email
});

Sentry.setContext('order', {
  id: order.id,
  total: order.total
});

// Capture exception with context
try {
  await processPayment(order);
} catch (error) {
  Sentry.captureException(error, {
    tags: {
      section: 'payment',
      paymentMethod: order.paymentMethod
    },
    extra: {
      orderId: order.id,
      amount: order.total
    }
  });
  throw error;
}
```

### 2. **Structured Logging**

```typescript
// ✅ Winston logger with error tracking
import winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

// Log with context
logger.error('Payment failed', {
  error: error.message,
  stack: error.stack,
  userId: user.id,
  orderId: order.id,
  amount: order.total
});

// Create child logger with default context
const paymentLogger = logger.child({ service: 'payment' });
paymentLogger.error('Transaction failed', { transactionId: tx.id });
```

## Error Handling Checklist

```
Error Detection:
□ All async functions wrapped in try/catch
□ Unhandled promise rejections caught
□ Input validation at entry points
□ Database errors handled
□ Network errors handled

Error Types:
□ Custom error classes for different scenarios
□ Operational vs programmer errors distinguished
□ HTTP status codes appropriate
□ Error codes consistent across API

Error Messages:
□ User-friendly messages (no technical jargon)
□ Actionable (tell user what to do)
□ No sensitive data exposed
□ Helpful for debugging in development
□ Generic in production

Error Recovery:
□ Retry logic for transient failures
□ Circuit breakers for external services
□ Graceful degradation strategies
□ Fallback values where appropriate
□ Cleanup in finally blocks

Monitoring:
□ Error tracking service configured (Sentry, etc.)
□ Structured logging implemented
□ Error rates monitored
□ Alerts for critical errors
□ Context included in error reports
```

## Resources

- [Error Handling in Node.js](https://nodejs.org/en/docs/guides/error-handling/)
- [React Error Boundaries](https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary)
- [Sentry Documentation](https://docs.sentry.io/)

---

**Remember**: Good error handling makes debugging easier, users happier, and systems more reliable. Fail gracefully, log thoroughly, and always provide actionable feedback.
