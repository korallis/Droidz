# UI/UX Design Guidelines

## Core Principles

1. **User-Centered Design** - Always design for the user's needs, not your preferences
2. **Consistency** - Maintain consistent patterns across the entire interface
3. **Accessibility First** - Design for all users, including those with disabilities
4. **Progressive Disclosure** - Show only what's needed, when it's needed
5. **Feedback & Affordance** - Make interactions clear and provide immediate feedback

## Design System Foundations

### Design Tokens
Use design tokens for all visual properties to ensure consistency and enable theming:

```css
/* ✅ Good: Use design tokens */
:root {
  /* Colors */
  --color-primary: #0066ff;
  --color-secondary: #6b7280;
  --color-success: #10b981;
  --color-error: #ef4444;
  --color-warning: #f59e0b;
  
  /* Spacing (8px grid) */
  --space-xs: 0.25rem;  /* 4px */
  --space-sm: 0.5rem;   /* 8px */
  --space-md: 1rem;     /* 16px */
  --space-lg: 1.5rem;   /* 24px */
  --space-xl: 2rem;     /* 32px */
  --space-2xl: 3rem;    /* 48px */
  
  /* Typography */
  --font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  --font-mono: "SF Mono", Monaco, "Cascadia Code", monospace;
  
  --text-xs: 0.75rem;   /* 12px */
  --text-sm: 0.875rem;  /* 14px */
  --text-base: 1rem;    /* 16px */
  --text-lg: 1.125rem;  /* 18px */
  --text-xl: 1.25rem;   /* 20px */
  --text-2xl: 1.5rem;   /* 24px */
  
  /* Border radius */
  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 1rem;
  --radius-full: 9999px;
  
  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
}
```

### ❌ Bad: Hardcoded values
```css
.button {
  padding: 12px 20px;  /* Should use design tokens */
  background: #0066ff; /* Should use --color-primary */
  font-size: 14px;     /* Should use --text-sm */
}
```

## Component Design Patterns

### Buttons

```tsx
// ✅ Good: Comprehensive button with states
interface ButtonProps {
  variant: 'primary' | 'secondary' | 'ghost' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  loading?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  children: React.ReactNode;
  onClick?: () => void;
}

export function Button({ 
  variant = 'primary',
  size = 'md',
  disabled = false,
  loading = false,
  leftIcon,
  rightIcon,
  children,
  onClick,
  ...props
}: ButtonProps) {
  return (
    <button
      className={cn(
        // Base styles
        "inline-flex items-center justify-center gap-2",
        "font-semibold rounded-md transition-all",
        "focus:outline-none focus:ring-2 focus:ring-offset-2",
        "disabled:opacity-50 disabled:cursor-not-allowed",
        
        // Variants
        variant === 'primary' && "bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500",
        variant === 'secondary' && "bg-gray-200 text-gray-900 hover:bg-gray-300 focus:ring-gray-500",
        variant === 'ghost' && "bg-transparent hover:bg-gray-100 focus:ring-gray-500",
        variant === 'danger' && "bg-red-600 text-white hover:bg-red-700 focus:ring-red-500",
        
        // Sizes
        size === 'sm' && "px-3 py-1.5 text-sm",
        size === 'md' && "px-4 py-2 text-base",
        size === 'lg' && "px-6 py-3 text-lg"
      )}
      disabled={disabled || loading}
      onClick={onClick}
      aria-busy={loading}
      {...props}
    >
      {loading && <Spinner size={size} />}
      {!loading && leftIcon}
      {children}
      {!loading && rightIcon}
    </button>
  );
}
```

### Form Inputs

```tsx
// ✅ Good: Accessible form input with error states
interface InputProps {
  label: string;
  id: string;
  type?: string;
  error?: string;
  hint?: string;
  required?: boolean;
  disabled?: boolean;
}

export function Input({ 
  label, 
  id, 
  type = 'text',
  error,
  hint,
  required = false,
  disabled = false,
  ...props 
}: InputProps) {
  return (
    <div className="space-y-1">
      <label 
        htmlFor={id}
        className="block text-sm font-medium text-gray-700 dark:text-gray-300"
      >
        {label}
        {required && <span className="text-red-500 ml-1" aria-label="required">*</span>}
      </label>
      
      <input
        id={id}
        type={type}
        disabled={disabled}
        required={required}
        aria-invalid={!!error}
        aria-describedby={error ? `${id}-error` : hint ? `${id}-hint` : undefined}
        className={cn(
          "w-full px-3 py-2 rounded-md",
          "border border-gray-300 dark:border-gray-600",
          "bg-white dark:bg-gray-800",
          "text-gray-900 dark:text-gray-100",
          "focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent",
          "disabled:bg-gray-100 disabled:cursor-not-allowed disabled:opacity-60",
          error && "border-red-500 focus:ring-red-500"
        )}
        {...props}
      />
      
      {hint && !error && (
        <p id={`${id}-hint`} className="text-sm text-gray-500">
          {hint}
        </p>
      )}
      
      {error && (
        <p id={`${id}-error`} className="text-sm text-red-600" role="alert">
          {error}
        </p>
      )}
    </div>
  );
}
```

## Accessibility (a11y) Requirements

### Semantic HTML
```tsx
// ✅ Good: Semantic HTML
<nav aria-label="Main navigation">
  <ul>
    <li><a href="/home">Home</a></li>
    <li><a href="/about">About</a></li>
  </ul>
</nav>

<main>
  <article>
    <header>
      <h1>Article Title</h1>
      <time dateTime="2025-01-15">January 15, 2025</time>
    </header>
    <p>Article content...</p>
  </article>
</main>

// ❌ Bad: Non-semantic divs
<div className="nav">
  <div className="nav-item" onClick={...}>Home</div>
</div>
```

### ARIA Labels & Roles
```tsx
// ✅ Good: Proper ARIA usage
<button 
  aria-label="Close dialog"
  aria-expanded={isOpen}
  onClick={handleClose}
>
  <XIcon aria-hidden="true" />
</button>

<div role="status" aria-live="polite">
  {message}
</div>

// Screen reader only text
<span className="sr-only">Loading...</span>
```

### Keyboard Navigation
```tsx
// ✅ Good: Full keyboard support
function Dropdown() {
  const handleKeyDown = (e: React.KeyboardEvent) => {
    switch (e.key) {
      case 'Escape':
        close();
        break;
      case 'ArrowDown':
        focusNextItem();
        break;
      case 'ArrowUp':
        focusPreviousItem();
        break;
      case 'Enter':
      case ' ':
        selectItem();
        break;
    }
  };
  
  return (
    <div 
      role="listbox"
      tabIndex={0}
      onKeyDown={handleKeyDown}
      aria-activedescendant={activeId}
    >
      {/* Items */}
    </div>
  );
}
```

### Color Contrast (WCAG AA)
- Normal text: 4.5:1 minimum
- Large text (18pt+): 3:1 minimum
- UI components & graphics: 3:1 minimum

```tsx
// ✅ Good: Sufficient contrast
<p className="text-gray-900 dark:text-white">
  Primary text with high contrast
</p>

// ❌ Bad: Insufficient contrast
<p className="text-gray-400 dark:text-gray-500">
  Low contrast text (hard to read)
</p>
```

## Layout & Spacing

### 8px Grid System
Always use multiples of 8 for spacing and dimensions:

```tsx
// ✅ Good: 8px grid
<div className="p-4 gap-2">    {/* 16px, 8px */}
  <div className="h-12 w-32" /> {/* 48px, 128px */}
</div>

// ❌ Bad: Random values
<div className="p-3 gap-5">
  <div className="h-17 w-45" />
</div>
```

### Responsive Breakpoints (Mobile-First)
```tsx
// ✅ Good: Mobile-first responsive
<div className="
  grid grid-cols-1          /* Mobile: 1 column */
  sm:grid-cols-2            /* Tablet: 2 columns */
  lg:grid-cols-3            /* Desktop: 3 columns */
  xl:grid-cols-4            /* Wide: 4 columns */
  gap-4 sm:gap-6 lg:gap-8   /* Progressive spacing */
">
```

### Whitespace & Hierarchy
```tsx
// ✅ Good: Clear visual hierarchy
<section className="space-y-8">
  <div className="space-y-2">
    <h2 className="text-2xl font-bold">Section Title</h2>
    <p className="text-gray-600">Section description</p>
  </div>
  
  <div className="space-y-6">
    <Card /> {/* Related content grouped together */}
    <Card />
  </div>
</section>
```

## Typography

### Type Scale
```tsx
// ✅ Good: Consistent type scale
<h1 className="text-4xl md:text-5xl font-bold">Main Heading</h1>
<h2 className="text-3xl md:text-4xl font-bold">Section Heading</h2>
<h3 className="text-2xl md:text-3xl font-semibold">Subsection</h3>
<p className="text-base md:text-lg leading-relaxed">Body text</p>
<small className="text-sm text-gray-600">Helper text</small>
```

### Line Height & Letter Spacing
```css
/* ✅ Good: Readable typography */
.text-display {
  font-size: 3rem;
  line-height: 1.2;      /* Tight for headings */
  letter-spacing: -0.02em;
}

.text-body {
  font-size: 1rem;
  line-height: 1.6;      /* Relaxed for body text */
  letter-spacing: 0;
}
```

## Color System

### Semantic Colors
```tsx
// ✅ Good: Semantic color usage
<div className="
  bg-blue-50 dark:bg-blue-950     /* Informational */
  border-l-4 border-blue-500
  text-blue-900 dark:text-blue-100
">

<div className="
  bg-red-50 dark:bg-red-950       /* Error */
  border-l-4 border-red-500
  text-red-900 dark:text-red-100
">

<div className="
  bg-green-50 dark:bg-green-950   /* Success */
  border-l-4 border-green-500
  text-green-900 dark:text-green-100
">
```

### Dark Mode
```tsx
// ✅ Good: Always include dark mode
<div className="
  bg-white dark:bg-gray-900
  text-gray-900 dark:text-white
  border-gray-200 dark:border-gray-800
">
  <h1 className="text-gray-900 dark:text-white">
    Title
  </h1>
  <p className="text-gray-600 dark:text-gray-400">
    Description
  </p>
</div>
```

## User Feedback & States

### Loading States
```tsx
// ✅ Good: Clear loading indication
{isLoading ? (
  <div className="flex items-center gap-2" role="status">
    <Spinner aria-hidden="true" />
    <span>Loading data...</span>
  </div>
) : (
  <DataTable data={data} />
)}
```

### Empty States
```tsx
// ✅ Good: Helpful empty state
function EmptyState() {
  return (
    <div className="text-center py-12">
      <EmptyIcon className="mx-auto h-12 w-12 text-gray-400" aria-hidden="true" />
      <h3 className="mt-2 text-sm font-semibold text-gray-900">No projects</h3>
      <p className="mt-1 text-sm text-gray-500">
        Get started by creating a new project.
      </p>
      <Button className="mt-6">
        <PlusIcon className="mr-2" aria-hidden="true" />
        New Project
      </Button>
    </div>
  );
}
```

### Error States
```tsx
// ✅ Good: Actionable error message
{error && (
  <div className="rounded-md bg-red-50 p-4" role="alert">
    <div className="flex">
      <ErrorIcon className="h-5 w-5 text-red-400" aria-hidden="true" />
      <div className="ml-3">
        <h3 className="text-sm font-medium text-red-800">
          Error loading data
        </h3>
        <p className="mt-1 text-sm text-red-700">
          {error.message}
        </p>
        <Button 
          variant="ghost" 
          size="sm"
          onClick={retry}
          className="mt-2"
        >
          Try again
        </Button>
      </div>
    </div>
  </div>
)}
```

## Micro-interactions

### Hover & Focus States
```tsx
// ✅ Good: Clear interactive states
<button className="
  transition-all duration-200
  hover:scale-105
  hover:shadow-md
  focus:outline-none
  focus:ring-2
  focus:ring-blue-500
  focus:ring-offset-2
  active:scale-95
">
  Click me
</button>
```

### Animations (Subtle & Purposeful)
```tsx
// ✅ Good: Smooth entrance animation
<div className="
  animate-in fade-in slide-in-from-bottom-4
  duration-300 ease-out
">
  Content appears smoothly
</div>

// Respect prefers-reduced-motion
<div className="
  motion-safe:animate-bounce
  motion-reduce:animate-none
">
```

## Mobile-First Considerations

### Touch Targets
```tsx
// ✅ Good: Minimum 44x44px touch targets
<button className="min-h-[44px] min-w-[44px] px-4">
  Tap
</button>

// Increase tap area without visual size
<button className="relative p-2">
  <span className="absolute inset-0 -m-2" />
  <Icon />
</button>
```

### Safe Areas (iOS/Android)
```css
/* ✅ Good: Respect device safe areas */
.container {
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
  padding-bottom: env(safe-area-inset-bottom);
}
```

## Design-to-Code Workflow

When converting designs to code:

1. **Analyze the Design**
   - Identify reusable components
   - Note color palette and typography
   - Map out spacing system

2. **Build from Atoms to Organisms**
   - Start with design tokens
   - Create base components (buttons, inputs)
   - Compose into larger patterns
   - Build full layouts

3. **Ensure Responsiveness**
   - Mobile-first approach
   - Test at all breakpoints
   - Progressive enhancement

4. **Add Interactivity**
   - Hover/focus states
   - Loading/error states
   - Smooth transitions
   - Keyboard navigation

5. **Accessibility Audit**
   - Semantic HTML
   - ARIA labels
   - Color contrast
   - Keyboard navigation
   - Screen reader testing

## Common Patterns

### Card Component
```tsx
// ✅ Good: Flexible card component
<Card className="overflow-hidden">
  <CardHeader>
    <CardTitle>Card Title</CardTitle>
    <CardDescription>Card description goes here</CardDescription>
  </CardHeader>
  <CardContent>
    Main content
  </CardContent>
  <CardFooter className="flex justify-between">
    <Button variant="ghost">Cancel</Button>
    <Button>Save</Button>
  </CardFooter>
</Card>
```

### Modal/Dialog
```tsx
// ✅ Good: Accessible modal
<Dialog open={isOpen} onOpenChange={setIsOpen}>
  <DialogContent aria-describedby="dialog-description">
    <DialogHeader>
      <DialogTitle>Dialog Title</DialogTitle>
    </DialogHeader>
    
    <p id="dialog-description">
      Dialog content goes here
    </p>
    
    <DialogFooter>
      <Button variant="ghost" onClick={close}>Cancel</Button>
      <Button onClick={confirm}>Confirm</Button>
    </DialogFooter>
  </DialogContent>
</Dialog>
```

**ALWAYS follow these design principles and patterns to create accessible, consistent, and user-friendly interfaces.**
