---
name: unit-test-generator
description: Auto-activates when user mentions writing tests, unit tests, test generation, or testing code. Generates comprehensive unit tests from existing code.
category: testing
---

# Unit Test Generator

Automatically generates unit tests with high coverage and real scenarios.

## When This Activates

- User says: "write tests", "generate tests", "test this function"
- When implementing TDD (test-driven-development skill)
- Before committing new code

## Test Frameworks

Auto-detect and use project's test framework:
- **JavaScript/TypeScript:** Jest, Vitest, Mocha
- **Python:** pytest, unittest
- **Go:** testing package
- **Rust:** built-in tests

## Process

1. **Analyze function/class:**
   - Input parameters
   - Return type
   - Side effects
   - Dependencies
   - Error conditions

2. **Generate test cases:**
   - Happy path (expected input → expected output)
   - Edge cases (empty, null, undefined, 0, negative)
   - Error cases (invalid input → throws error)
   - Boundary conditions

3. **Create test file** following project conventions

## Example: JavaScript/TypeScript

### Code to Test
```typescript
export function calculateDiscount(price: number, discountPercent: number): number {
  if (price < 0) throw new Error('Price cannot be negative');
  if (discountPercent < 0 || discountPercent > 100) {
    throw new Error('Discount must be between 0 and 100');
  }
  return price - (price * discountPercent / 100);
}
```

### Generated Tests
```typescript
import { describe, it, expect } from 'vitest';
import { calculateDiscount } from './discount';

describe('calculateDiscount', () => {
  describe('happy path', () => {
    it('calculates 10% discount correctly', () => {
      expect(calculateDiscount(100, 10)).toBe(90);
    });

    it('calculates 50% discount correctly', () => {
      expect(calculateDiscount(200, 50)).toBe(100);
    });

    it('handles 0% discount', () => {
      expect(calculateDiscount(100, 0)).toBe(100);
    });

    it('handles 100% discount', () => {
      expect(calculateDiscount(100, 100)).toBe(0);
    });
  });

  describe('edge cases', () => {
    it('handles decimal prices', () => {
      expect(calculateDiscount(99.99, 10)).toBeCloseTo(89.99, 2);
    });

    it('handles decimal discounts', () => {
      expect(calculateDiscount(100, 12.5)).toBe(87.5);
    });

    it('handles very large prices', () => {
      expect(calculateDiscount(1_000_000, 10)).toBe(900_000);
    });
  });

  describe('error cases', () => {
    it('throws error for negative price', () => {
      expect(() => calculateDiscount(-10, 10)).toThrow('Price cannot be negative');
    });

    it('throws error for negative discount', () => {
      expect(() => calculateDiscount(100, -5)).toThrow('Discount must be between 0 and 100');
    });

    it('throws error for discount over 100', () => {
      expect(() => calculateDiscount(100, 150)).toThrow('Discount must be between 0 and 100');
    });
  });
});
```

## Patterns

### Testing Async Functions
```typescript
describe('fetchUser', () => {
  it('fetches user successfully', async () => {
    const user = await fetchUser('123');
    expect(user).toEqual({ id: '123', name: 'John' });
  });

  it('handles 404 error', async () => {
    await expect(fetchUser('invalid')).rejects.toThrow('User not found');
  });

  it('handles network error', async () => {
    // Mock network failure
    await expect(fetchUser('123')).rejects.toThrow('Network error');
  });
});
```

### Testing with Mocks
```typescript
import { vi } from 'vitest';

describe('sendEmail', () => {
  it('sends email via email service', async () => {
    const mockSend = vi.fn().mockResolvedValue({ success: true });
    const emailService = { send: mockSend };
    
    await sendEmail(emailService, 'user@example.com', 'Hello');
    
    expect(mockSend).toHaveBeenCalledWith({
      to: 'user@example.com',
      subject: 'Hello',
      body: expect.any(String)
    });
  });
});
```

### Testing React Components
```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { LoginForm } from './LoginForm';

describe('LoginForm', () => {
  it('renders email and password inputs', () => {
    render(<LoginForm />);
    expect(screen.getByLabelText('Email')).toBeInTheDocument();
    expect(screen.getByLabelText('Password')).toBeInTheDocument();
  });

  it('shows validation error for invalid email', async () => {
    render(<LoginForm />);
    const emailInput = screen.getByLabelText('Email');
    
    fireEvent.change(emailInput, { target: { value: 'invalid' } });
    fireEvent.blur(emailInput);
    
    expect(await screen.findByText('Invalid email')).toBeInTheDocument();
  });

  it('calls onSubmit with form data', async () => {
    const mockSubmit = vi.fn();
    render(<LoginForm onSubmit={mockSubmit} />);
    
    fireEvent.change(screen.getByLabelText('Email'), { 
      target: { value: 'user@example.com' } 
    });
    fireEvent.change(screen.getByLabelText('Password'), {
      target: { value: 'password123' }
    });
    fireEvent.click(screen.getByText('Login'));
    
    await waitFor(() => {
      expect(mockSubmit).toHaveBeenCalledWith({
        email: 'user@example.com',
        password: 'password123'
      });
    });
  });
});
```

## Coverage Goals

Aim for:
- **Unit tests:** 80%+ code coverage
- **Critical paths:** 100% coverage
- **All error conditions:** Tested

## Test Organization

```
src/
├── components/
│   ├── Button.tsx
│   └── Button.test.tsx          # Colocated tests
├── utils/
│   ├── calculations.ts
│   └── calculations.test.ts
└── __tests__/                    # Integration tests
    └── auth-flow.test.ts
```

## Best Practices

✅ **DO:**
- Test behavior, not implementation
- One assertion per test (when possible)
- Clear test names describing what's tested
- Test edge cases and errors
- Mock external dependencies

❌ **DON'T:**
- Test implementation details
- Have multiple unrelated assertions
- Skip error case tests
- Test the test framework itself
- Mock too much (integration value lost)

**Generate tests, run them, ensure they pass, then present to user.**
