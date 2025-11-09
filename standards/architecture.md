# Architecture Standards

Defines architectural patterns and project structure that Droidz droids must follow.

## Project Structure

```
project/
├── src/
│   ├── components/      # UI components
│   ├── lib/            # Utilities and helpers
│   ├── services/       # API and business logic
│   ├── types/          # TypeScript type definitions
│   ├── hooks/          # Custom React hooks (if React)
│   └── app/ or pages/  # Routing (framework-specific)
├── tests/              # Test files
├── public/             # Static assets
├── droidz/             # Droidz specs and products
│   ├── product/        # Product planning docs
│   └── specs/          # Feature specifications
└── standards/          # Project standards (this file)
```

## Separation of Concerns

### Layer Architecture

```
Presentation Layer (UI Components)
    ↓ calls
Business Logic Layer (Services)
    ↓ calls
Data Layer (API/Database)
```

**Rules:**
- UI components should NOT contain business logic
- Business logic should NOT know about UI
- Data layer should be abstracted behind services

### Example

```typescript
// ❌ Bad: Business logic in component
function UserProfile() {
  const [user, setUser] = useState(null);
  
  useEffect(() => {
    fetch('/api/users/123')
      .then(res => res.json())
      .then(data => {
        // Business logic in component
        const fullName = `${data.firstName} ${data.lastName}`;
        const age = calculateAge(data.birthDate);
        setUser({ ...data, fullName, age });
      });
  }, []);
  
  return <div>{user?.fullName}</div>;
}

// ✅ Good: Separation of concerns
// services/userService.ts
export async function getUserProfile(id: string) {
  const data = await api.get(`/users/${id}`);
  return {
    ...data,
    fullName: `${data.firstName} ${data.lastName}`,
    age: calculateAge(data.birthDate),
  };
}

// components/UserProfile.tsx
function UserProfile({ userId }: Props) {
  const { data: user } = useQuery(['user', userId], () => 
    getUserProfile(userId)
  );
  
  return <div>{user?.fullName}</div>;
}
```

## Component Patterns

### Component Types

1. **Page Components** - Route-level components
2. **Feature Components** - Complex, feature-specific components
3. **UI Components** - Reusable, generic components
4. **Layout Components** - Structural components

```
src/components/
├── ui/              # Generic UI components (Button, Input, etc.)
├── features/        # Feature-specific components
│   ├── auth/
│   ├── dashboard/
│   └── profile/
└── layouts/         # Layout components (Header, Footer, etc.)
```

### Component Composition

```typescript
// ✅ Good: Composable components
function ProfileCard({ user }: Props) {
  return (
    <Card>
      <Card.Header>
        <Avatar src={user.avatar} />
        <Card.Title>{user.name}</Card.Title>
      </Card.Header>
      <Card.Content>
        <UserBio bio={user.bio} />
      </Card.Content>
    </Card>
  );
}

// ❌ Bad: Monolithic component
function ProfileCard({ user }: Props) {
  return (
    <div className="card">
      <div className="header">
        <img src={user.avatar} className="avatar" />
        <h3 className="title">{user.name}</h3>
      </div>
      <div className="content">
        <p className="bio">{user.bio}</p>
      </div>
    </div>
  );
}
```

## State Management

### Local State
Use for component-specific state:
```typescript
const [isOpen, setIsOpen] = useState(false);
```

### Shared State
Use appropriate tool for shared state:
- **Context API**: For simple global state (theme, auth)
- **Zustand/Redux**: For complex app state
- **React Query/SWR**: For server state

### Server State vs Client State

```typescript
// ✅ Server state: React Query
const { data: users } = useQuery(['users'], fetchUsers);

// ✅ Client state: useState/Zustand
const [selectedUserId, setSelectedUserId] = useState(null);
```

## API Layer

### Service Pattern

```typescript
// services/api.ts
class ApiService {
  private baseURL = '/api';
  
  async get<T>(endpoint: string): Promise<T> {
    const response = await fetch(`${this.baseURL}${endpoint}`);
    if (!response.ok) throw new ApiError(response);
    return response.json();
  }
  
  async post<T>(endpoint: string, data: unknown): Promise<T> {
    // Implementation
  }
}

export const api = new ApiService();

// services/userService.ts
export const userService = {
  getAll: () => api.get<User[]>('/users'),
  getById: (id: string) => api.get<User>(`/users/${id}`),
  create: (data: CreateUserDto) => api.post<User>('/users', data),
};
```

## Error Boundaries

```typescript
// Use error boundaries for React components
class ErrorBoundary extends React.Component {
  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    logError(error, errorInfo);
  }
  
  render() {
    if (this.state.hasError) {
      return <ErrorFallback />;
    }
    return this.props.children;
  }
}
```

## Performance

### Code Splitting
```typescript
// ✅ Lazy load heavy components
const Dashboard = lazy(() => import('./Dashboard'));
const AdminPanel = lazy(() => import('./AdminPanel'));
```

### Memoization
```typescript
// ✅ Memoize expensive calculations
const expensiveValue = useMemo(() => 
  calculateComplexValue(data),
  [data]
);

// ✅ Memoize callbacks
const handleClick = useCallback(() => {
  doSomething(id);
}, [id]);
```

## Customization

**To customize for your project**, edit this file to match your architecture patterns. Add framework-specific patterns (Next.js, SvelteKit, etc.) as needed.
