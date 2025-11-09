# Coding Conventions

This file defines coding standards that all Droidz implementers must follow.

## File Naming

- **Components**: PascalCase (e.g., `UserProfile.tsx`)
- **Utilities**: camelCase (e.g., `formatDate.ts`)
- **Constants**: SCREAMING_SNAKE_CASE file (e.g., `API_CONSTANTS.ts`)
- **Tests**: Match source file with `.test` or `.spec` suffix

## Code Structure

### TypeScript/JavaScript

```typescript
// 1. Imports (grouped)
import { useState } from 'react';
import { Button } from '@/components/ui';
import { formatDate } from '@/lib/utils';

// 2. Types/Interfaces
interface Props {
  name: string;
  age: number;
}

// 3. Constants
const MAX_RETRIES = 3;

// 4. Main component/function
export function Component({ name, age }: Props) {
  // Implementation
}

// 5. Helper functions (if small)
function helper() {
  // ...
}
```

### Naming Conventions

- **Variables**: camelCase
- **Functions**: camelCase, verb-first (e.g., `getUserData`, `formatDate`)
- **Classes**: PascalCase
- **Types/Interfaces**: PascalCase
- **Constants**: SCREAMING_SNAKE_CASE
- **Private methods**: prefix with `_` (e.g., `_internalHelper`)

## Comments

```typescript
// ❌ Bad: Obvious comment
// Set x to 5
const x = 5;

// ✅ Good: Explains WHY
// Use 5-second timeout to allow network latency
const TIMEOUT_MS = 5000;

// ✅ Good: Complex logic explanation
/**
 * Calculates user score using weighted algorithm
 * Weight factors: activity (30%), engagement (50%), tenure (20%)
 */
function calculateScore(user: User): number {
  // Implementation
}
```

**When to comment:**
- Complex algorithms or business logic
- Non-obvious workarounds
- Important assumptions
- TODOs with context

**When NOT to comment:**
- Obvious code
- Redundant function descriptions (use TypeScript types instead)
- Version history (use git)

## Error Handling

```typescript
// ✅ Specific error types
try {
  await fetchData();
} catch (error) {
  if (error instanceof NetworkError) {
    // Handle network errors
  } else if (error instanceof AuthError) {
    // Handle auth errors
  } else {
    // Unknown error
    throw error;
  }
}

// ✅ User-friendly messages
try {
  await saveData();
} catch (error) {
  toast.error("Failed to save. Please try again.");
  logger.error("Save failed:", error);
}
```

## Async/Await

```typescript
// ✅ Preferred: async/await
async function fetchUser(id: string) {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}

// ❌ Avoid: Promise chains (unless necessary)
function fetchUser(id: string) {
  return fetch(`/api/users/${id}`)
    .then(res => res.json());
}
```

## Formatting

- **Indentation**: 2 spaces
- **Semicolons**: Required
- **Quotes**: Single quotes for strings, double for JSX
- **Line length**: Max 100 characters (soft limit)
- **Trailing commas**: Always in multi-line

```typescript
// ✅ Good
const user = {
  name: 'Alice',
  age: 30,
  email: 'alice@example.com',
};

// ❌ Bad
const user = {
  name: 'Alice',
  age: 30,
  email: 'alice@example.com'
}
```

## Testing

```typescript
// ✅ Descriptive test names
describe('UserProfile', () => {
  it('should display user name', () => {
    // Test
  });
  
  it('should handle missing avatar gracefully', () => {
    // Test
  });
});

// ❌ Bad test names
describe('UserProfile', () => {
  it('works', () => {
    // Test
  });
});
```

## Customization

**To customize for your project**, edit this file to match your team's conventions. Droidz droids will follow these rules when implementing features.
