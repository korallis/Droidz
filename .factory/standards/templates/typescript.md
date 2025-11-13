# TypeScript Development Standards

## Strict Mode Configuration (Required)

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,                           // Enable all strict type checks
    "noUncheckedIndexedAccess": true,        // Index signatures return T | undefined
    "noImplicitReturns": true,               // Functions must explicitly return
    "noFallthroughCasesInSwitch": true,     // No implicit fallthrough in switches
    "exactOptionalPropertyTypes": true,      // Optional props can't be undefined
    "noImplicitOverride": true,              // Require explicit override keyword
    "allowUnusedLabels": false,              // Error on unused labels
    "allowUnreachableCode": false,           // Error on unreachable code
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true                     // Skip type checking of .d.ts files
  }
}
```

## Type Annotations (Required)

```typescript
// ✅ Good: Explicit type annotations for function parameters and returns
function calculateTotal(items: number[], taxRate: number = 0.1): number {
  const subtotal = items.reduce((sum, item) => sum + item, 0);
  return subtotal * (1 + taxRate);
}

// ✅ Good: Interfaces for object shapes
interface User {
  id: string;
  email: string;
  name: string;
  age: number;
  isActive: boolean;
}

// ✅ Good: Type for function signatures
type UserTransformer = (user: User) => Partial<User>;

// ❌ Bad: Implicit any types
function processData(data) { // Implicit 'any'
  return data.value; // No type safety
}
```

## Interfaces vs Types

```typescript
// ✅ Good: Use interfaces for object definitions (preferred for extensibility)
interface Product {
  id: string;
  name: string;
  price: number;
}

// Interface extension
interface DetailedProduct extends Product {
  description: string;
  images: string[];
}

// ✅ Good: Use types for unions, intersections, and utilities
type Status = 'pending' | 'approved' | 'rejected';
type Result<T> = { success: true; data: T } | { success: false; error: string };

// Type intersection
type Timestamped = { createdAt: Date; updatedAt: Date };
type TimestampedProduct = Product & Timestamped;

// ❌ Bad: Don't use type aliases for simple object definitions
type BadProduct = {  // Use interface instead
  id: string;
  name: string;
};
```

## Generic Types

```typescript
// ✅ Good: Generic functions with constraints
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

// ✅ Good: Generic interfaces
interface ApiResponse<T> {
  data: T;
  status: number;
  message: string;
}

// Usage
const userResponse: ApiResponse<User> = {
  data: { id: '1', email: 'user@example.com', name: 'John', age: 30, isActive: true },
  status: 200,
  message: 'Success'
};

// ✅ Good: Generic type with multiple parameters
function merge<T extends object, U extends object>(obj1: T, obj2: U): T & U {
  return { ...obj1, ...obj2 };
}
```

## Utility Types

```typescript
// ✅ Good: Use built-in utility types
interface User {
  id: string;
  email: string;
  name: string;
  password: string;
}

// Pick specific properties
type UserPreview = Pick<User, 'id' | 'name'>;

// Omit properties
type PublicUser = Omit<User, 'password'>;

// Make all properties optional
type PartialUser = Partial<User>;

// Make all properties required
type RequiredUser = Required<Partial<User>>;

// Make all properties readonly
type ImmutableUser = Readonly<User>;

// Record type for maps
type UserMap = Record<string, User>;

// Return type of function
function getUser(): User { /* ... */ }
type GetUserReturn = ReturnType<typeof getUser>; // User

// Parameters of function
type GetUserParams = Parameters<typeof getUser>; // []
```

## Discriminated Unions (Tagged Unions)

```typescript
// ✅ Good: Use discriminated unions for type-safe state management
type AsyncState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: string };

function handleState<T>(state: AsyncState<T>) {
  switch (state.status) {
    case 'idle':
      return 'Not started';
    case 'loading':
      return 'Loading...';
    case 'success':
      return state.data; // Type-safe access to data
    case 'error':
      return state.error; // Type-safe access to error
  }
}

// ✅ Good: API result type
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

function divide(a: number, b: number): Result<number, string> {
  if (b === 0) {
    return { success: false, error: 'Division by zero' };
  }
  return { success: true, data: a / b };
}

// Usage with type narrowing
const result = divide(10, 2);
if (result.success) {
  console.log(result.data); // TypeScript knows this is safe
} else {
  console.error(result.error);
}
```

## Type Guards and Narrowing

```typescript
// ✅ Good: User-defined type guards
interface Cat {
  type: 'cat';
  meow: () => void;
}

interface Dog {
  type: 'dog';
  bark: () => void;
}

type Animal = Cat | Dog;

// Type predicate
function isCat(animal: Animal): animal is Cat {
  return animal.type === 'cat';
}

function handleAnimal(animal: Animal) {
  if (isCat(animal)) {
    animal.meow(); // TypeScript knows it's a Cat
  } else {
    animal.bark(); // TypeScript knows it's a Dog
  }
}

// ✅ Good: typeof type guards
function processValue(value: string | number) {
  if (typeof value === 'string') {
    return value.toUpperCase(); // String methods available
  }
  return value.toFixed(2); // Number methods available
}

// ✅ Good: instanceof type guards
class HttpError extends Error {
  constructor(public statusCode: number, message: string) {
    super(message);
  }
}

function handleError(error: Error) {
  if (error instanceof HttpError) {
    console.log(`HTTP Error: ${error.statusCode}`);
  }
}
```

## Async/Await with Types

```typescript
// ✅ Good: Typed async functions
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  if (!response.ok) {
    throw new Error('Failed to fetch user');
  }
  return response.json();
}

// ✅ Good: Typed error handling
async function safelyFetchUser(id: string): Promise<Result<User, string>> {
  try {
    const user = await fetchUser(id);
    return { success: true, data: user };
  } catch (error) {
    if (error instanceof Error) {
      return { success: false, error: error.message };
    }
    return { success: false, error: 'Unknown error' };
  }
}
```

## Enums vs Union Types

```typescript
// ❌ Avoid: Enums (use const objects or union types instead)
enum Status {
  Pending = 'pending',
  Approved = 'approved',
  Rejected = 'rejected'
}

// ✅ Good: Union types with const assertion
const Status = {
  Pending: 'pending',
  Approved: 'approved',
  Rejected: 'rejected'
} as const;

type Status = typeof Status[keyof typeof Status];

// Or simpler
type Status = 'pending' | 'approved' | 'rejected';

// Benefits: Lighter weight, no runtime code, better tree-shaking
```

## Const Assertions

```typescript
// ✅ Good: Use const assertions for literal types
const routes = {
  home: '/',
  about: '/about',
  contact: '/contact'
} as const;

type Route = typeof routes[keyof typeof routes]; // '/' | '/about' | '/contact'

// ✅ Good: Readonly arrays
const colors = ['red', 'green', 'blue'] as const;
type Color = typeof colors[number]; // 'red' | 'green' | 'blue'

// ✅ Good: Object with literal types
const config = {
  api: {
    url: 'https://api.example.com',
    timeout: 5000
  }
} as const;
```

## Template Literal Types

```typescript
// ✅ Good: Use template literal types for dynamic string types
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';
type Route = `/api/${string}`;
type Endpoint = `${HttpMethod} ${Route}`;

// Usage
const endpoint: Endpoint = 'GET /api/users'; // Valid
// const invalid: Endpoint = 'PATCH /api/users'; // Error

// ✅ Good: Building complex types
type EventName = 'click' | 'focus' | 'blur';
type EventHandler<T extends EventName> = `on${Capitalize<T>}`;

type Handlers = {
  [K in EventName as EventHandler<K>]: (event: Event) => void;
};
// Result: { onClick, onFocus, onBlur }
```

## Conditional Types

```typescript
// ✅ Good: Conditional types for complex type logic
type IsArray<T> = T extends Array<any> ? true : false;

type A = IsArray<string[]>; // true
type B = IsArray<string>;   // false

// ✅ Good: Extract non-nullable types
type NonNullable<T> = T extends null | undefined ? never : T;

// ✅ Good: Flatten nested arrays
type Flatten<T> = T extends Array<infer U> ? U : T;

type Str = Flatten<string[]>; // string
type Num = Flatten<number>;   // number
```

## Type-Safe Event Handlers

```typescript
// ✅ Good: Typed event handlers
interface FormElements extends HTMLFormControlsCollection {
  email: HTMLInputElement;
  password: HTMLInputElement;
}

interface FormElement extends HTMLFormElement {
  readonly elements: FormElements;
}

function handleSubmit(event: React.FormEvent<FormElement>) {
  event.preventDefault();
  const email = event.currentTarget.elements.email.value; // Type-safe!
  const password = event.currentTarget.elements.password.value;
}
```

## Advanced Patterns

### Builder Pattern

```typescript
// ✅ Good: Type-safe builder pattern
class QueryBuilder<T> {
  private filters: Array<(item: T) => boolean> = [];
  
  where(predicate: (item: T) => boolean): this {
    this.filters.push(predicate);
    return this;
  }
  
  execute(data: T[]): T[] {
    return data.filter(item =>
      this.filters.every(filter => filter(item))
    );
  }
}

// Usage
const users = new QueryBuilder<User>()
  .where(u => u.age > 18)
  .where(u => u.isActive)
  .execute(allUsers);
```

### Branded Types

```typescript
// ✅ Good: Branded types for type safety
type Brand<T, TBrand> = T & { __brand: TBrand };

type UserId = Brand<string, 'UserId'>;
type Email = Brand<string, 'Email'>;

function getUserById(id: UserId): User { /* ... */ }

const userId = 'user-123' as UserId;
getUserById(userId); // OK

const email = 'user@example.com' as Email;
// getUserById(email); // Error: Email is not assignable to UserId
```

## Never Use

- ❌ Never use `any` type (use `unknown` if type is truly unknown)
- ❌ Never use type assertions (`as`) unless absolutely necessary
- ❌ Never use `Function` type (use proper function signature)
- ❌ Never use `Object` or `{}` types (use `object` or specific interface)
- ❌ Never use enums (use union types or const objects)
- ❌ Never ignore `@ts-ignore` or `@ts-expect-error` without good reason
- ❌ Never use `var` declarations (use `const` or `let`)
- ❌ Never mutate function parameters
- ❌ Never use `eval()` or `with` statements
- ❌ Never skip strict mode configuration

## Code Quality Tools

```json
// .eslintrc.json
{
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:@typescript-eslint/recommended-requiring-type-checking"
  ],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "project": "./tsconfig.json"
  },
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/explicit-function-return-type": "warn",
    "@typescript-eslint/no-unused-vars": ["error", { "argsIgnorePattern": "^_" }]
  }
}
```

## Documentation with JSDoc

```typescript
/**
 * Calculates the total price including tax
 * @param items - Array of item prices
 * @param taxRate - Tax rate as decimal (e.g., 0.1 for 10%)
 * @returns Total price with tax applied
 * @throws {Error} If taxRate is negative
 */
function calculateTotal(items: number[], taxRate: number): number {
  if (taxRate < 0) {
    throw new Error('Tax rate cannot be negative');
  }
  const subtotal = items.reduce((sum, item) => sum + item, 0);
  return subtotal * (1 + taxRate);
}
```
