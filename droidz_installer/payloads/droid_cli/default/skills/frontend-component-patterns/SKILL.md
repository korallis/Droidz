---
name: frontend-component-patterns
description: Build reusable, composable, and maintainable React/Vue/Angular components following established design patterns like compound components, render props, custom hooks, and HOCs. Use when creating component libraries, implementing component composition, building reusable UI elements, designing prop APIs, managing component state patterns, implementing controlled vs uncontrolled components, creating compound components, using render props or children as functions, building custom hooks, or establishing component architecture standards.
---

# Frontend Component Patterns - Building Reusable React Components

## When to use this skill

- Creating reusable component libraries
- Implementing component composition patterns
- Building flexible, configurable UI components
- Designing intuitive component prop APIs
- Managing component state with patterns
- Implementing controlled vs uncontrolled components
- Creating compound components (e.g., Tabs, Accordion)
- Using render props or children as functions
- Building custom React hooks for shared logic
- Implementing Higher-Order Components (HOCs)
- Establishing component architecture standards
- Creating accessible, keyboard-navigable components

## When to use this skill

- Designing React component architecture, improving component reusability, managing state, or solving common UI patterns.
- When working on related tasks or features
- During development that requires this expertise

**Use when**: Designing React component architecture, improving component reusability, managing state, or solving common UI patterns.

## Core Principles

1. **Composition Over Inheritance** - Build complex UIs from simple components
2. **Single Responsibility** - Each component does one thing well
3. **Props Down, Events Up** - Unidirectional data flow
4. **Separation of Concerns** - Logic separate from presentation
5. **Accessibility First** - ARIA, keyboard navigation, semantic HTML

## Component Patterns

### 1. **Presentational vs Container Components**

```typescript
// ❌ Mixed concerns - logic + presentation together
function UserProfile() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    fetch(`/api/users/${userId}`)
      .then(r => r.json())
      .then(setUser)
      .finally(() => setLoading(false));
  }, [userId]);
  
  if (loading) return <div>Loading...</div>;
  
  return (
    <div className="profile">
      <img src={user.avatar} alt={user.name} />
      <h1>{user.name}</h1>
      <p>{user.bio}</p>
    </div>
  );
}

// ✅ Separated - Container handles logic
function UserProfileContainer({ userId }: { userId: string }) {
  const { data: user, isLoading } = useUser(userId);
  
  if (isLoading) return <LoadingSpinner />;
  if (!user) return <NotFound />;
  
  return <UserProfileView user={user} />;
}

// ✅ Presentational - Pure display component
interface UserProfileViewProps {
  user: {
    avatar: string;
    name: string;
    bio: string;
  };
}

function UserProfileView({ user }: UserProfileViewProps) {
  return (
    <div className="profile">
      <img src={user.avatar} alt={user.name} />
      <h1>{user.name}</h1>
      <p>{user.bio}</p>
    </div>
  );
}
```

### 2. **Compound Components**

```typescript
// ✅ Flexible, composable API
interface TabsProps {
  children: React.ReactNode;
  defaultValue?: string;
}

interface TabsContextValue {
  activeTab: string;
  setActiveTab: (value: string) => void;
}

const TabsContext = React.createContext<TabsContextValue | null>(null);

function Tabs({ children, defaultValue }: TabsProps) {
  const [activeTab, setActiveTab] = useState(defaultValue || '');
  
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
}

function TabsList({ children }: { children: React.ReactNode }) {
  return <div className="tabs-list" role="tablist">{children}</div>;
}

function TabsTrigger({ value, children }: { value: string; children: React.ReactNode }) {
  const context = useContext(TabsContext);
  if (!context) throw new Error('TabsTrigger must be inside Tabs');
  
  const isActive = context.activeTab === value;
  
  return (
    <button
      role="tab"
      aria-selected={isActive}
      onClick={() => context.setActiveTab(value)}
      className={isActive ? 'active' : ''}
    >
      {children}
    </button>
  );
}

function TabsContent({ value, children }: { value: string; children: React.ReactNode }) {
  const context = useContext(TabsContext);
  if (!context) throw new Error('TabsContent must be inside Tabs');
  
  if (context.activeTab !== value) return null;
  
  return <div role="tabpanel">{children}</div>;
}

// Export as compound component
export { Tabs, TabsList, TabsTrigger, TabsContent };

// Usage - flexible and intuitive
function App() {
  return (
    <Tabs defaultValue="account">
      <TabsList>
        <TabsTrigger value="account">Account</TabsTrigger>
        <TabsTrigger value="password">Password</TabsTrigger>
        <TabsTrigger value="notifications">Notifications</TabsTrigger>
      </TabsList>
      
      <TabsContent value="account">
        <AccountSettings />
      </TabsContent>
      
      <TabsContent value="password">
        <PasswordSettings />
      </TabsContent>
      
      <TabsContent value="notifications">
        <NotificationSettings />
      </TabsContent>
    </Tabs>
  );
}
```

### 3. **Render Props Pattern**

```typescript
// ✅ Flexible rendering with render props
interface MousePositionProps {
  children: (position: { x: number; y: number }) => React.ReactNode;
}

function MousePosition({ children }: MousePositionProps) {
  const [position, setPosition] = useState({ x: 0, y: 0 });
  
  useEffect(() => {
    const handleMove = (e: MouseEvent) => {
      setPosition({ x: e.clientX, y: e.clientY });
    };
    
    window.addEventListener('mousemove', handleMove);
    return () => window.removeEventListener('mousemove', handleMove);
  }, []);
  
  return <>{children(position)}</>;
}

// Usage - consumer controls rendering
function App() {
  return (
    <MousePosition>
      {({ x, y }) => (
        <div>
          Mouse is at ({x}, {y})
        </div>
      )}
    </MousePosition>
  );
}
```

### 4. **Custom Hooks (Modern Alternative)**

```typescript
// ✅ Extract reusable logic as hook
function useMousePosition() {
  const [position, setPosition] = useState({ x: 0, y: 0 });
  
  useEffect(() => {
    const handleMove = (e: MouseEvent) => {
      setPosition({ x: e.clientX, y: e.clientY });
    };
    
    window.addEventListener('mousemove', handleMove);
    return () => window.removeEventListener('mousemove', handleMove);
  }, []);
  
  return position;
}

// Usage - cleaner than render props
function App() {
  const { x, y } = useMousePosition();
  
  return (
    <div>
      Mouse is at ({x}, {y})
    </div>
  );
}

// ✅ More custom hooks examples
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);
  
  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);
  
  return debouncedValue;
}

function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    const stored = localStorage.getItem(key);
    return stored ? JSON.parse(stored) : initialValue;
  });
  
  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);
  
  return [value, setValue] as const;
}
```

### 5. **Higher-Order Components (Legacy Pattern)**

```typescript
// ✅ HOC for adding functionality
function withLoading<P extends object>(
  Component: React.ComponentType<P>
) {
  return function WithLoadingComponent(
    props: P & { isLoading: boolean }
  ) {
    if (props.isLoading) {
      return <LoadingSpinner />;
    }
    
    return <Component {...props} />;
  };
}

// Usage
const UserListWithLoading = withLoading(UserList);

<UserListWithLoading users={users} isLoading={loading} />

// Note: Custom hooks are now preferred over HOCs
```

## State Management Patterns

### 1. **Props vs State**

```typescript
// ✅ Props - passed from parent
interface ButtonProps {
  label: string;        // Display text
  onClick: () => void;  // Callback
  disabled?: boolean;   // Optional config
}

function Button({ label, onClick, disabled }: ButtonProps) {
  return (
    <button onClick={onClick} disabled={disabled}>
      {label}
    </button>
  );
}

// ✅ State - internal to component
function Counter() {
  const [count, setCount] = useState(0); // Local state
  
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  );
}

// ✅ Controlled vs Uncontrolled
// Controlled - value from props (parent controls)
function ControlledInput({ value, onChange }: { 
  value: string; 
  onChange: (value: string) => void; 
}) {
  return (
    <input 
      value={value} 
      onChange={(e) => onChange(e.target.value)} 
    />
  );
}

// Uncontrolled - internal state (component controls)
function UncontrolledInput() {
  const inputRef = useRef<HTMLInputElement>(null);
  
  const handleSubmit = () => {
    console.log(inputRef.current?.value);
  };
  
  return (
    <>
      <input ref={inputRef} defaultValue="initial" />
      <button onClick={handleSubmit}>Submit</button>
    </>
  );
}
```

### 2. **Lifting State Up**

```typescript
// ❌ Duplicated state - siblings can't communicate
function ParentBad() {
  return (
    <>
      <SearchBox /> {/* Has own search state */}
      <ResultsList /> {/* Has own search state */}
    </>
  );
}

// ✅ Shared state in parent
function ParentGood() {
  const [searchQuery, setSearchQuery] = useState('');
  
  return (
    <>
      <SearchBox query={searchQuery} onQueryChange={setSearchQuery} />
      <ResultsList query={searchQuery} />
    </>
  );
}
```

### 3. **Context for Deep Props**

```typescript
// ❌ Prop drilling - passing through many levels
function App() {
  const [theme, setTheme] = useState('light');
  return <Layout theme={theme} setTheme={setTheme} />;
}

function Layout({ theme, setTheme }) {
  return <Sidebar theme={theme} setTheme={setTheme} />;
}

function Sidebar({ theme, setTheme }) {
  return <ThemeToggle theme={theme} setTheme={setTheme} />;
}

// ✅ Context - direct access at any level
interface ThemeContextValue {
  theme: string;
  setTheme: (theme: string) => void;
}

const ThemeContext = createContext<ThemeContextValue | null>(null);

function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState('light');
  
  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) throw new Error('useTheme must be inside ThemeProvider');
  return context;
}

// Usage - no prop drilling
function ThemeToggle() {
  const { theme, setTheme } = useTheme();
  
  return (
    <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
      Toggle {theme} theme
    </button>
  );
}
```

## Performance Optimization

### 1. **React.memo - Prevent Re-renders**

```typescript
// ❌ Re-renders on every parent render
function ExpensiveComponent({ data }: { data: string }) {
  console.log('Rendering...');
  return <div>{data}</div>;
}

// ✅ Only re-renders when props change
const ExpensiveComponent = memo(function ExpensiveComponent({ 
  data 
}: { 
  data: string 
}) {
  console.log('Rendering...');
  return <div>{data}</div>;
});

// ✅ Custom comparison function
const ExpensiveList = memo(
  function ExpensiveList({ items }: { items: Item[] }) {
    return <ul>{items.map(item => <li key={item.id}>{item.name}</li>)}</ul>;
  },
  (prevProps, nextProps) => {
    // Only re-render if items array length changed
    return prevProps.items.length === nextProps.items.length;
  }
);
```

### 2. **useMemo - Cache Expensive Calculations**

```typescript
function ProductList({ products, filters }: { products: Product[]; filters: Filters }) {
  // ❌ Recalculates on every render
  const filteredProducts = products.filter(p => matchesFilters(p, filters));
  
  // ✅ Only recalculates when dependencies change
  const filteredProducts = useMemo(() => {
    return products.filter(p => matchesFilters(p, filters));
  }, [products, filters]);
  
  return (
    <div>
      {filteredProducts.map(p => (
        <ProductCard key={p.id} product={p} />
      ))}
    </div>
  );
}
```

### 3. **useCallback - Stable Function References**

```typescript
function Parent() {
  const [count, setCount] = useState(0);
  
  // ❌ New function on every render (causes child re-render)
  const handleClick = () => {
    console.log('clicked');
  };
  
  // ✅ Stable function reference
  const handleClick = useCallback(() => {
    console.log('clicked');
  }, []); // No dependencies - never changes
  
  return (
    <>
      <p>{count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
      <MemoizedChild onClick={handleClick} />
    </>
  );
}

const MemoizedChild = memo(function Child({ onClick }: { onClick: () => void }) {
  console.log('Child rendering');
  return <button onClick={onClick}>Click me</button>;
});
```

### 4. **Code Splitting & Lazy Loading**

```typescript
// ✅ Lazy load heavy components
const HeavyChart = lazy(() => import('./HeavyChart'));
const AdminPanel = lazy(() => import('./AdminPanel'));

function App() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <Routes>
        <Route path="/dashboard" element={<HeavyChart />} />
        <Route path="/admin" element={<AdminPanel />} />
      </Routes>
    </Suspense>
  );
}
```

## Accessibility Patterns

### 1. **Semantic HTML & ARIA**

```typescript
// ✅ Accessible button
function AccessibleButton({ label, onClick }: { label: string; onClick: () => void }) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-label={label}
    >
      {label}
    </button>
  );
}

// ✅ Accessible modal
function Modal({ isOpen, onClose, children }: { 
  isOpen: boolean; 
  onClose: () => void; 
  children: React.ReactNode; 
}) {
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
      // Focus trap, ESC key handler, etc.
    }
    return () => {
      document.body.style.overflow = '';
    };
  }, [isOpen]);
  
  if (!isOpen) return null;
  
  return (
    <div
      role="dialog"
      aria-modal="true"
      className="modal-overlay"
      onClick={onClose}
    >
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        {children}
        <button onClick={onClose} aria-label="Close modal">×</button>
      </div>
    </div>
  );
}

// ✅ Accessible form
function SignupForm() {
  return (
    <form>
      <label htmlFor="email">Email</label>
      <input
        id="email"
        type="email"
        required
        aria-required="true"
        aria-describedby="email-error"
      />
      <span id="email-error" role="alert" className="error">
        Please enter a valid email
      </span>
      
      <button type="submit">Sign Up</button>
    </form>
  );
}
```

### 2. **Keyboard Navigation**

```typescript
// ✅ Keyboard-accessible dropdown
function Dropdown({ options }: { options: string[] }) {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedIndex, setSelectedIndex] = useState(0);
  
  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' || e.key === ' ') {
      setIsOpen(!isOpen);
    } else if (e.key === 'ArrowDown') {
      setSelectedIndex((i) => Math.min(i + 1, options.length - 1));
    } else if (e.key === 'ArrowUp') {
      setSelectedIndex((i) => Math.max(i - 1, 0));
    } else if (e.key === 'Escape') {
      setIsOpen(false);
    }
  };
  
  return (
    <div
      role="combobox"
      aria-expanded={isOpen}
      aria-controls="dropdown-options"
      tabIndex={0}
      onKeyDown={handleKeyDown}
    >
      <button onClick={() => setIsOpen(!isOpen)}>
        Select option
      </button>
      
      {isOpen && (
        <ul id="dropdown-options" role="listbox">
          {options.map((opt, i) => (
            <li
              key={opt}
              role="option"
              aria-selected={i === selectedIndex}
              className={i === selectedIndex ? 'selected' : ''}
            >
              {opt}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
```

## Component Design Checklist

```
Structure:
□ Single responsibility per component
□ Presentational vs container separation
□ Proper props typing (TypeScript)
□ Default props defined
□ Prop validation for critical inputs

State Management:
□ State at lowest necessary level
□ Lifted state when needed for sharing
□ Context for deep prop drilling
□ No prop mutations
□ Controlled components for forms

Performance:
□ memo() for expensive components
□ useMemo() for expensive calculations
□ useCallback() for stable callbacks
□ Code splitting for large components
□ Lazy loading for routes

Accessibility:
□ Semantic HTML elements
□ ARIA labels and roles
□ Keyboard navigation support
□ Focus management
□ Screen reader tested

Reusability:
□ Configurable via props
□ Composable with children
□ No hardcoded values
□ Clear, documented API
□ Example usage provided
```

## Resources

- [React Documentation](https://react.dev/)
- [React Patterns](https://reactpatterns.com/)
- [Compound Components](https://kentcdodds.com/blog/compound-components-with-react-hooks)
- [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)

---

**Remember**: Great components are simple, reusable, accessible, and performant. Start simple, add complexity only when needed.
