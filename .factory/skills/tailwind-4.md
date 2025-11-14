# Tailwind CSS 4.0 Guidelines

## Core Principles

1. **Utility-First** - Use Tailwind utilities instead of custom CSS
2. **Responsive Design** - Mobile-first breakpoints
3. **Semantic Color** - Use Tailwind's semantic colors (not hardcoded values)
4. **Component Composition** - Extract reusable patterns to components
5. **Modern Features** - Leverage Tailwind 4.0's new features

## Tailwind 4.0 New Features

### CSS Variables (Theme Integration)
```css
/* Use native CSS variables */
:root {
  --color-brand: theme(colors.blue.500);
  --font-heading: theme(fontFamily.sans);
}
```

### Container Queries
```html
<!-- ✅ Good: Use container queries for responsive components -->
<div className="@container">
  <div className="@md:grid-cols-2 grid">
    <div>Content</div>
  </div>
</div>
```

## Layout Patterns

### ✅ Good
```tsx
// Modern flexbox with gap
<div className="flex items-center gap-4">
  <Avatar />
  <div className="flex flex-col">
    <h3 className="text-lg font-semibold">Name</h3>
    <p className="text-sm text-gray-600">Description</p>
  </div>
</div>

// Grid with auto-fit
<div className="grid grid-cols-[repeat(auto-fit,minmax(250px,1fr))] gap-6">
  {items.map(item => <Card key={item.id} {...item} />)}
</div>

// Centered container with prose
<div className="mx-auto max-w-prose px-4">
  <article className="prose prose-slate dark:prose-invert">
    {content}
  </article>
</div>
```

### ❌ Bad
```tsx
// Don't use inline styles
<div style={{ display: 'flex', gap: '1rem' }}>

// Don't use hardcoded values
<div className="mt-[23px] ml-[17px]">

// Don't break responsive patterns
<div className="grid md:grid-cols-2 sm:grid-cols-1">  // Wrong order!
```

## Responsive Design (Mobile-First)

### ✅ Good
```tsx
// Mobile-first breakpoints
<div className="
  flex flex-col          // Mobile: stack vertically
  md:flex-row            // Tablet: horizontal
  lg:gap-8               // Desktop: more spacing
  xl:max-w-7xl           // Wide: constrain width
">
  <aside className="w-full md:w-64" />
  <main className="flex-1" />
</div>

// Responsive text
<h1 className="text-2xl md:text-4xl lg:text-5xl font-bold">
  Title
</h1>
```

## Dark Mode

### ✅ Good
```tsx
// Always include dark mode variants
<div className="bg-white dark:bg-gray-900">
  <h1 className="text-gray-900 dark:text-white">
    Title
  </h1>
  <p className="text-gray-600 dark:text-gray-300">
    Content
  </p>
</div>

// Use semantic colors
<button className="bg-blue-500 hover:bg-blue-600 dark:bg-blue-600 dark:hover:bg-blue-700">
  Click me
</button>
```

## Component Composition

### ✅ Good
```tsx
// Extract reusable patterns
const buttonClasses = "
  px-4 py-2 rounded-lg
  font-semibold text-sm
  transition-colors duration-200
  focus:outline-none focus:ring-2 focus:ring-offset-2
";

const primaryClasses = `
  ${buttonClasses}
  bg-blue-500 text-white
  hover:bg-blue-600
  focus:ring-blue-500
  dark:bg-blue-600 dark:hover:bg-blue-700
`;

<button className={primaryClasses}>
  Click me
</button>
```

## Accessibility with Tailwind

### ✅ Good
```tsx
// Focus states
<button className="
  focus:outline-none 
  focus:ring-2 
  focus:ring-blue-500 
  focus:ring-offset-2
  dark:focus:ring-offset-gray-900
">

// Screen reader only
<span className="sr-only">Loading...</span>

// Hover and focus together
<a className="
  underline 
  hover:text-blue-600 
  focus:text-blue-600
  focus:outline-none
">
```

## Animations & Transitions

### ✅ Good
```tsx
// Smooth transitions
<div className="transition-all duration-300 ease-in-out">
  <img className="transform hover:scale-105 transition-transform" />
</div>

// Custom animations
<div className="animate-fade-in">  {/* Define in tailwind.config */}
  Content
</div>
```

## Forms

### ✅ Good
```tsx
<input 
  type="text"
  className="
    w-full px-4 py-2
    border border-gray-300 rounded-lg
    focus:border-blue-500 focus:ring-2 focus:ring-blue-200
    dark:bg-gray-800 dark:border-gray-600 dark:text-white
    dark:focus:border-blue-400 dark:focus:ring-blue-800
    disabled:bg-gray-100 disabled:cursor-not-allowed
  "
/>

<label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
  Email Address
</label>
```

## Performance Tips

1. **Use `@apply` sparingly** - Prefer utilities in templates
2. **Purge unused CSS** - Ensure proper content paths in config
3. **Avoid deep nesting** - Keep specificity low
4. **Use `arbitrary values` wisely** - Prefer theme values

### ❌ Bad
```css
/* Don't overuse @apply */
.my-component {
  @apply flex items-center justify-between p-4 bg-white rounded-lg shadow-md;
  @apply dark:bg-gray-800 dark:text-white;
  @apply hover:shadow-lg transition-shadow;
}
```

### ✅ Good
```tsx
// Use utilities directly
<div className="flex items-center justify-between p-4 bg-white dark:bg-gray-800 rounded-lg shadow-md hover:shadow-lg transition-shadow">
```

**ALWAYS use Tailwind utilities following these patterns. Keep designs responsive, accessible, and dark-mode compatible.**
