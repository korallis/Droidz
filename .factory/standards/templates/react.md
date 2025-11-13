# React 18/19 Development Standards

## Functional Components (Required)

```tsx
// ✅ Good: Functional component with TypeScript
interface UserProfileProps {
  user: User;
  onUpdate: (user: User) => void;
}

export function UserProfile({ user, onUpdate }: UserProfileProps) {
  return (
    <div>
      <h2>{user.name}</h2>
      <button onClick={() => onUpdate(user)}>Update</button>
    </div>
  );
}

// ❌ Bad: Class components (avoid in new code)
class UserProfile extends React.Component<UserProfileProps> {
  render() {
    return <div>{this.props.user.name}</div>;
  }
}
```

## Hooks Best Practices

### useState

```tsx
// ✅ Good: Clear state initialization
const [count, setCount] = useState(0);
const [user, setUser] = useState<User | null>(null);
const [items, setItems] = useState<Item[]>([]);

// ✅ Good: Functional updates for state that depends on previous value
setCount(prevCount => prevCount + 1);

setItems(prevItems => [...prevItems, newItem]);

// ❌ Bad: Direct state mutation
items.push(newItem); // NEVER mutate state directly
setItems(items);
```

### useEffect

```tsx
// ✅ Good: Effect with cleanup
useEffect(() => {
  const subscription = api.subscribe(data => {
    setData(data);
  });
  
  // Cleanup function
  return () => {
    subscription.unsubscribe();
  };
}, [/* dependencies */]);

// ✅ Good: Effect with dependencies
useEffect(() => {
  fetchUser(userId).then(setUser);
}, [userId]); // Re-run when userId changes

// ❌ Bad: Missing dependencies
useEffect(() => {
  fetchUser(userId).then(setUser); // userId should be in dependency array
}, []); // eslint will warn about this

// ❌ Bad: Infinite loop
useEffect(() => {
  setCount(count + 1); // Creates infinite loop!
});
```

### useCallback

```tsx
// ✅ Good: Memoize callbacks passed to optimized child components
const handleSubmit = useCallback((data: FormData) => {
  submitForm(data);
}, []); // No dependencies

const handleUserUpdate = useCallback((user: User) => {
  updateUser(userId, user);
}, [userId]); // Recreate when userId changes

// ❌ Bad: Unnecessary useCallback
const handleClick = useCallback(() => {
  console.log('clicked');
}, []); // Not passed to memoized component, no benefit
```

### useMemo

```tsx
// ✅ Good: Memoize expensive computations
const filteredItems = useMemo(() => {
  return items.filter(item => item.status === 'active')
              .sort((a, b) => b.priority - a.priority);
}, [items]);

// ✅ Good: Memoize object/array creation
const config = useMemo(() => ({
  theme: 'dark',
  language: 'en',
  features: ['feature1', 'feature2']
}), []); // Stable reference

// ❌ Bad: Premature optimization
const doubled = useMemo(() => count * 2, [count]); // Simple calculation, don't memoize
```

### useRef

```tsx
// ✅ Good: Accessing DOM elements
function TextInput() {
  const inputRef = useRef<HTMLInputElement>(null);
  
  useEffect(() => {
    inputRef.current?.focus();
  }, []);
  
  return <input ref={inputRef} type="text" />;
}

// ✅ Good: Storing mutable values that don't trigger re-renders
function Timer() {
  const intervalRef = useRef<number | null>(null);
  
  const startTimer = () => {
    intervalRef.current = setInterval(() => {
      console.log('tick');
    }, 1000);
  };
  
  const stopTimer = () => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
    }
  };
  
  return <button onClick={startTimer}>Start</button>;
}
```

## React 18/19 Concurrent Features

### useTransition

```tsx
import { useState, useTransition } from 'react';

function SearchComponent() {
  const [isPending, startTransition] = useTransition();
  const [input, setInput] = useState('');
  const [searchQuery, setSearchQuery] = useState('');
  
  function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
    // Urgent: Update input immediately
    setInput(e.target.value);
    
    // Non-urgent: Defer expensive search
    startTransition(() => {
      setSearchQuery(e.target.value);
    });
  }
  
  return (
    <>
      <input value={input} onChange={handleChange} />
      {isPending && <Spinner />}
      <SearchResults query={searchQuery} />
    </>
  );
}
```

### useOptimistic (React 19)

```tsx
import { useOptimistic } from 'react';

function TodoList({ todos, addTodo }: { todos: Todo[]; addTodo: (text: string) => Promise<void> }) {
  const [optimisticTodos, addOptimisticTodo] = useOptimistic(
    todos,
    (state, newTodo: string) => [
      ...state,
      { id: `temp-${Date.now()}`, text: newTodo, pending: true }
    ]
  );
  
  async function handleSubmit(formData: FormData) {
    const text = formData.get('text') as string;
    addOptimisticTodo(text);
    await addTodo(text);
  }
  
  return (
    <form action={handleSubmit}>
      {optimisticTodos.map(todo => (
        <div key={todo.id}>
          {todo.text} {todo.pending && '(Saving...)'}
        </div>
      ))}
      <input name="text" />
      <button type="submit">Add</button>
    </form>
  );
}
```

### useDeferredValue

```tsx
import { useDeferredValue, useMemo } from 'react';

function SearchPage({ query }: { query: string }) {
  const deferredQuery = useDeferredValue(query);
  
  // Expensive filtering operation
  const results = useMemo(() => {
    return searchDatabase(deferredQuery);
  }, [deferredQuery]);
  
  // Show stale UI with lower priority
  return (
    <div style={{ opacity: query !== deferredQuery ? 0.5 : 1 }}>
      {results.map(result => <div key={result.id}>{result.title}</div>)}
    </div>
  );
}
```

## Component Patterns

### Compound Components

```tsx
// ✅ Good: Compound component pattern with context
interface TabsContextValue {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

const TabsContext = createContext<TabsContextValue | null>(null);

export function Tabs({ children, defaultTab }: { children: React.ReactNode; defaultTab: string }) {
  const [activeTab, setActiveTab] = useState(defaultTab);
  
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
}

Tabs.List = function TabsList({ children }: { children: React.ReactNode }) {
  return <div className="tabs-list">{children}</div>;
};

Tabs.Tab = function Tab({ value, children }: { value: string; children: React.ReactNode }) {
  const context = useContext(TabsContext);
  if (!context) throw new Error('Tab must be used within Tabs');
  
  return (
    <button
      onClick={() => context.setActiveTab(value)}
      className={context.activeTab === value ? 'active' : ''}
    >
      {children}
    </button>
  );
};

Tabs.Panel = function TabPanel({ value, children }: { value: string; children: React.ReactNode }) {
  const context = useContext(TabsContext);
  if (!context) throw new Error('Panel must be used within Tabs');
  
  return context.activeTab === value ? <div>{children}</div> : null;
};

// Usage
<Tabs defaultTab="overview">
  <Tabs.List>
    <Tabs.Tab value="overview">Overview</Tabs.Tab>
    <Tabs.Tab value="details">Details</Tabs.Tab>
  </Tabs.List>
  <Tabs.Panel value="overview">Overview content</Tabs.Panel>
  <Tabs.Panel value="details">Details content</Tabs.Panel>
</Tabs>
```

### Render Props

```tsx
// ✅ Good: Render prop pattern for flexible rendering
interface MouseTrackerProps {
  render: (position: { x: number; y: number }) => React.ReactNode;
}

function MouseTracker({ render }: MouseTrackerProps) {
  const [position, setPosition] = useState({ x: 0, y: 0 });
  
  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      setPosition({ x: e.clientX, y: e.clientY });
    };
    
    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, []);
  
  return <>{render(position)}</>;
}

// Usage
<MouseTracker render={({ x, y }) => (
  <p>Mouse is at {x}, {y}</p>
)} />
```

### Custom Hooks

```tsx
// ✅ Good: Extract reusable logic into custom hooks
function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(error);
      return initialValue;
    }
  });
  
  const setValue = (value: T | ((val: T) => T)) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(error);
    }
  };
  
  return [storedValue, setValue] as const;
}

// Usage
const [name, setName] = useLocalStorage('name', 'Anonymous');
```

## Performance Optimization

### React.memo

```tsx
// ✅ Good: Memoize components that receive stable props
interface UserCardProps {
  user: User;
  onSelect: (id: string) => void;
}

export const UserCard = React.memo(function UserCard({ user, onSelect }: UserCardProps) {
  return (
    <div onClick={() => onSelect(user.id)}>
      <h3>{user.name}</h3>
      <p>{user.email}</p>
    </div>
  );
});

// With custom comparison
export const UserCard = React.memo(
  UserCard,
  (prevProps, nextProps) => prevProps.user.id === nextProps.user.id
);
```

### Code Splitting

```tsx
import { lazy, Suspense } from 'react';

// ✅ Good: Lazy load heavy components
const HeavyComponent = lazy(() => import('./HeavyComponent'));

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <HeavyComponent />
    </Suspense>
  );
}
```

## Error Boundaries

```tsx
// ✅ Good: Error boundary for graceful error handling
class ErrorBoundary extends React.Component<
  { children: React.ReactNode; fallback: React.ReactNode },
  { hasError: boolean }
> {
  constructor(props: any) {
    super(props);
    this.state = { hasError: false };
  }
  
  static getDerivedStateFromError(error: Error) {
    return { hasError: true };
  }
  
  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
  }
  
  render() {
    if (this.state.hasError) {
      return this.props.fallback;
    }
    return this.props.children;
  }
}

// Usage
<ErrorBoundary fallback={<ErrorMessage />}>
  <App />
</ErrorBoundary>
```

## Context Best Practices

```tsx
// ✅ Good: Well-structured context with custom hook
interface ThemeContextValue {
  theme: 'light' | 'dark';
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextValue | null>(null);

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  
  const toggleTheme = useCallback(() => {
    setTheme(prev => prev === 'light' ? 'dark' : 'light');
  }, []);
  
  const value = useMemo(() => ({ theme, toggleTheme }), [theme, toggleTheme]);
  
  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

// Custom hook for consuming context
export function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within ThemeProvider');
  }
  return context;
}
```

## Forms and Controlled Components

```tsx
// ✅ Good: Controlled form with validation
function LoginForm() {
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });
  const [errors, setErrors] = useState<Record<string, string>>({});
  
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    // Clear error when user types
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };
  
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const newErrors: Record<string, string> = {};
    
    if (!formData.email) newErrors.email = 'Email is required';
    if (!formData.password) newErrors.password = 'Password is required';
    
    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }
    
    // Submit form
    submitLogin(formData);
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <input
        type="email"
        name="email"
        value={formData.email}
        onChange={handleChange}
      />
      {errors.email && <span className="error">{errors.email}</span>}
      
      <input
        type="password"
        name="password"
        value={formData.password}
        onChange={handleChange}
      />
      {errors.password && <span className="error">{errors.password}</span>}
      
      <button type="submit">Login</button>
    </form>
  );
}
```

## Testing

```tsx
// Component.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Counter } from './Counter';

describe('Counter', () => {
  it('renders initial count', () => {
    render(<Counter initialCount={0} />);
    expect(screen.getByText('Count: 0')).toBeInTheDocument();
  });
  
  it('increments count when button clicked', async () => {
    const user = userEvent.setup();
    render(<Counter initialCount={0} />);
    
    await user.click(screen.getByRole('button', { name: /increment/i }));
    expect(screen.getByText('Count: 1')).toBeInTheDocument();
  });
});
```

## Never

- ❌ Never mutate state directly
- ❌ Never use class components in new code
- ❌ Never call hooks conditionally or in loops
- ❌ Never forget cleanup in useEffect
- ❌ Never use index as key for dynamic lists
- ❌ Never pass new objects/functions as props without memoization
- ❌ Never use `bind()` or arrow functions in render
- ❌ Never store props in state (use props directly or derive from props)
- ❌ Never use `any` type in TypeScript
- ❌ Never forget to add dependencies to useEffect, useCallback, useMemo
