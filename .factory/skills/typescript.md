# TypeScript Coding Standards

## Core Principles

1. **Type Safety First** - Always use explicit types for function parameters and return values
2. **Strict Mode** - Enable strict mode in tsconfig.json
3. **No `any`** - Use `unknown` when type is truly unknown
4. **Interfaces over Types** - Use `interface` for objects, `type` for unions/intersections

## Type Definitions

### ✅ Good
```typescript
// Explicit function signatures
interface User {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}

function getUser(id: string): Promise<User> {
  return fetch(`/api/users/${id}`).then(r => r.json());
}

// Use utility types
type PartialUser = Partial<User>;
type UserWithoutEmail = Omit<User, 'email'>;
```

### ❌ Bad
```typescript
// Implicit any
function getUser(id) {
  return fetch(`/api/users/${id}`).then(r => r.json());
}

// Using any
function processData(data: any) {
  return data.map((item: any) => item.value);
}
```

## React + TypeScript

### ✅ Good
```typescript
// Function components with explicit props
interface ButtonProps {
  onClick: () => void;
  children: React.ReactNode;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}

export function Button({ 
  onClick, 
  children, 
  variant = 'primary',
  disabled = false 
}: ButtonProps) {
  return (
    <button 
      onClick={onClick} 
      disabled={disabled}
      className={`btn-${variant}`}
    >
      {children}
    </button>
  );
}

// Typed hooks
const [count, setCount] = useState<number>(0);
const [user, setUser] = useState<User | null>(null);
```

### ❌ Bad
```typescript
// Untyped props
export function Button(props) {
  return <button onClick={props.onClick}>{props.children}</button>;
}

// Implicit state types
const [data, setData] = useState(null);
```

## Error Handling

### ✅ Good
```typescript
// Type-safe error handling
type Result<T, E = Error> = 
  | { success: true; value: T }
  | { success: false; error: E };

async function fetchData(id: string): Promise<Result<User>> {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) {
      return { success: false, error: new Error('Failed to fetch') };
    }
    const user = await response.json();
    return { success: true, value: user };
  } catch (error) {
    return { 
      success: false, 
      error: error instanceof Error ? error : new Error('Unknown error')
    };
  }
}
```

## Async/Await

### ✅ Good
```typescript
// Explicit Promise return types
async function loadUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}

// Proper error handling
async function safeLoadUser(id: string): Promise<User | null> {
  try {
    return await loadUser(id);
  } catch (error) {
    console.error('Failed to load user:', error);
    return null;
  }
}
```

## Union Types & Discriminated Unions

### ✅ Good
```typescript
// Discriminated unions for state
type LoadingState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: string };

function UserDisplay({ state }: { state: LoadingState<User> }) {
  switch (state.status) {
    case 'idle':
      return <div>Click to load</div>;
    case 'loading':
      return <div>Loading...</div>;
    case 'success':
      return <div>Hello, {state.data.name}</div>;
    case 'error':
      return <div>Error: {state.error}</div>;
  }
}
```

## TSConfig Requirements

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  }
}
```

**ALWAYS follow these TypeScript standards in every file you create or modify.**
