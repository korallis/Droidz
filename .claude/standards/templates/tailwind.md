# Tailwind CSS v4 Development Standards

## Installation and Configuration

```bash
# Install Tailwind CSS v4
npm install tailwindcss @tailwindcss/postcss

# Or with Vite plugin (recommended)
npm install tailwindcss @tailwindcss/vite
```

### CSS-First Configuration

```css
/* app.css */
@import "tailwindcss";

@theme {
  /* Custom spacing scale */
  --spacing: 0.25rem;
  
  /* Custom colors (oklch format) */
  --color-primary-50: oklch(0.98 0.02 240);
  --color-primary-100: oklch(0.95 0.05 240);
  --color-primary-500: oklch(0.60 0.20 240);
  --color-primary-900: oklch(0.30 0.15 240);
  
  /* Custom fonts */
  --font-display: "Satoshi", sans-serif;
  --font-mono: "Fira Code", monospace;
  
  /* Custom breakpoints */
  --breakpoint-xs: 480px;
  --breakpoint-3xl: 1920px;
  
  /* Custom animations */
  --ease-fluid: cubic-bezier(0.3, 0, 0, 1);
  --ease-snappy: cubic-bezier(0.2, 0, 0, 1);
}
```

### Vite Plugin Setup

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  plugins: [tailwindcss()],
});
```

## Utility-First Approach

```html
<!-- ✅ Good: Utility-first classes -->
<div class="flex items-center justify-between p-4 bg-white rounded-lg shadow-md">
  <h2 class="text-2xl font-bold text-gray-900">Title</h2>
  <button class="px-4 py-2 bg-primary-500 text-white rounded hover:bg-primary-600 transition-colors">
    Click me
  </button>
</div>

<!-- ❌ Bad: Custom classes for simple styling -->
<div class="header-container">
  <h2 class="header-title">Title</h2>
  <button class="header-button">Click me</button>
</div>
```

## Responsive Design

```html
<!-- ✅ Good: Mobile-first responsive design -->
<div class="w-full sm:w-1/2 lg:w-1/3 xl:w-1/4">
  <img src="..." class="w-full h-48 object-cover sm:h-64 lg:h-80" />
</div>

<!-- ✅ Good: Responsive grid -->
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
  {items.map(item => <Card key={item.id} {...item} />)}
</div>

<!-- ✅ Good: Single breakpoint targeting (v4 feature) -->
<div class="max-sm:hidden sm:@md:block @lg:hidden">
  Only shows between sm and md
</div>
```

## Tailwind v4 New Features

### Dynamic Utility Values

```html
<!-- ✅ Good: Dynamic grid columns (no configuration needed!) -->
<div class="grid-cols-7">
  <!-- Creates a 7-column grid automatically -->
</div>

<!-- ✅ Good: Dynamic spacing -->
<div class="mt-17 px-23 w-128">
  <!-- All spacing values work out of the box -->
</div>

<!-- ✅ Good: Custom data attributes -->
<div class="data-open:bg-blue-500" data-open="true">
  <!-- No need to configure data-* variants -->
</div>
```

### Container Queries

```html
<!-- ✅ Good: Container queries (no plugin needed in v4!) -->
<div class="@container">
  <div class="@sm:text-lg @md:text-xl @lg:text-2xl">
    Text size based on container width
  </div>
</div>

<!-- ✅ Good: Named containers -->
<div class="@container/sidebar">
  <div class="@lg/sidebar:flex-col">
    Targets specific container
  </div>
</div>

<!-- ✅ Good: Max-width container queries -->
<div class="@container">
  <div class="@max-md:hidden">
    Hidden when container is smaller than md
  </div>
</div>
```

### 3D Transforms

```html
<!-- ✅ Good: 3D transform utilities -->
<div class="transform-style-3d">
  <div class="rotate-x-45 rotate-y-30 translate-z-10">
    3D transformed element
  </div>
</div>

<!-- ✅ Good: Perspective -->
<div class="perspective-1000">
  <div class="rotate-y-45 transition-transform hover:rotate-y-0">
    Card flip effect
  </div>
</div>
```

### Enhanced Gradients

```html
<!-- ✅ Good: Linear gradients with angles -->
<div class="bg-linear-45 from-blue-500 to-purple-500">
  45-degree gradient
</div>

<!-- ✅ Good: Radial gradients -->
<div class="bg-radial-at-center from-yellow-400 via-red-500 to-pink-500">
  Radial gradient
</div>

<!-- ✅ Good: Conic gradients -->
<div class="bg-conic from-blue-500 via-purple-500 to-pink-500">
  Conic gradient
</div>

<!-- ✅ Good: Color interpolation -->
<div class="bg-linear-to-r/oklch from-blue-500 to-green-500">
  OKLCH interpolation for vivid colors
</div>
```

### New Utilities

```html
<!-- ✅ Good: Inset shadows -->
<div class="shadow-md inset-shadow-sm">
  Outer shadow with inner shadow
</div>

<!-- ✅ Good: Field sizing (auto-resize textareas) -->
<textarea class="field-sizing-content">
  Auto-resizes based on content!
</textarea>

<!-- ✅ Good: Color scheme -->
<div class="color-scheme-dark">
  <!-- Forces dark scrollbars, form controls, etc. -->
</div>

<!-- ✅ Good: Starting style animations -->
<div class="starting:opacity-0 starting:scale-90 transition-all">
  Animates in on first render
</div>
```

### not-* Variant

```html
<!-- ✅ Good: Negate selectors -->
<div class="not-hover:opacity-75">
  Reduced opacity when NOT hovered
</div>

<!-- ✅ Good: Negate media queries -->
<div class="not-supports-grid:flex">
  Fallback for browsers without grid support
</div>

<!-- ✅ Good: Negate with complex selectors -->
<div class="not-[&:last-child]:border-b">
  Border except on last child
</div>
```

## Color System (P3 Colors)

```css
/* ✅ Good: Use OKLCH for wider color gamut */
@theme {
  --color-brand-500: oklch(0.60 0.20 240);
  --color-accent-500: oklch(0.70 0.25 150);
}
```

```html
<!-- Usage -->
<div class="bg-brand-500 text-accent-500">
  Vivid P3 colors on supported displays
</div>
```

## Component Patterns

### Extract Components (Not Classes)

```tsx
// ✅ Good: Extract to React/Vue component
export function Button({ variant = 'primary', size = 'md', children, ...props }) {
  return (
    <button
      className={cn(
        "px-4 py-2 font-medium rounded-lg transition-colors",
        variant === 'primary' && "bg-primary-500 text-white hover:bg-primary-600",
        variant === 'secondary' && "bg-gray-200 text-gray-900 hover:bg-gray-300",
        size === 'sm' && "text-sm px-3 py-1.5",
        size === 'lg' && "text-lg px-6 py-3"
      )}
      {...props}
    >
      {children}
    </button>
  );
}

// ❌ Bad: Extract to @apply in CSS
.btn {
  @apply px-4 py-2 bg-primary-500 text-white rounded;
}
```

### Conditional Classes

```tsx
import { cn } from '@/lib/utils';

// ✅ Good: Use cn() utility for conditional classes
<div
  className={cn(
    "p-4 rounded-lg",
    isActive && "bg-blue-500",
    isError && "bg-red-500",
    size === 'large' && "text-xl"
  )}
>
  Content
</div>
```

## Dark Mode

```css
/* app.css */
@theme {
  :root {
    --color-background: oklch(1 0 0);
    --color-foreground: oklch(0.15 0 0);
  }
  
  .dark {
    --color-background: oklch(0.15 0 0);
    --color-foreground: oklch(0.95 0 0);
  }
}
```

```html
<!-- ✅ Good: Dark mode variants -->
<div class="bg-background text-foreground">
  <p class="text-gray-900 dark:text-gray-100">
    Automatically adapts to dark mode
  </p>
</div>

<!-- ✅ Good: Dark mode with custom colors -->
<div class="bg-white dark:bg-gray-900">
  <button class="bg-primary-500 dark:bg-primary-400">
    Click me
  </button>
</div>
```

## Performance Best Practices

```html
<!-- ✅ Good: Use will-change sparingly -->
<div class="will-change-transform hover:scale-110 transition-transform">
  Only use on elements that will actually animate
</div>

<!-- ✅ Good: Prefer transform over position -->
<div class="translate-x-4">
  Better than: left-4 (which doesn't use GPU)
</div>

<!-- ✅ Good: Use contain for performance -->
<div class="contain-layout contain-paint">
  Isolated rendering context
</div>
```

## Accessibility

```html
<!-- ✅ Good: Focus states -->
<button class="focus:outline-none focus-visible:ring-2 focus-visible:ring-primary-500">
  Keyboard accessible
</button>

<!-- ✅ Good: Screen reader utilities -->
<span class="sr-only">
  Hidden visually but available to screen readers
</span>

<!-- ✅ Good: Reduced motion support -->
<div class="motion-safe:animate-bounce motion-reduce:animate-none">
  Respects user preferences
</div>
```

## Custom Plugins (v4 Approach)

```css
/* Instead of JavaScript plugins, define utilities in CSS */
@utility btn {
  @apply px-4 py-2 font-medium rounded-lg transition-colors;
}

@utility btn-primary {
  @apply btn bg-primary-500 text-white hover:bg-primary-600;
}

@utility btn-secondary {
  @apply btn bg-gray-200 text-gray-900 hover:bg-gray-300;
}
```

## Arbitrary Values

```html
<!-- ✅ Good: Use arbitrary values when needed -->
<div class="top-[117px] w-[762px]">
  Custom values
</div>

<!-- ✅ Good: Arbitrary values with CSS variables -->
<div class="bg-[var(--brand-color)]">
  Use CSS variables
</div>

<!-- ✅ Good: Arbitrary properties -->
<div class="[mask-type:alpha]">
  Any CSS property
</div>
```

## Organization Strategies

```html
<!-- ✅ Good: Group related utilities -->
<div class="
  /* Layout */
  flex items-center justify-between
  /* Spacing */
  p-4 gap-4
  /* Colors */
  bg-white text-gray-900
  /* Border */
  border border-gray-200 rounded-lg
  /* Effects */
  shadow-md hover:shadow-lg
  /* Transitions */
  transition-shadow duration-200
">
  Well-organized classes
</div>
```

## Never

- ❌ Never use `@apply` for simple one-off utility combinations
- ❌ Never create custom CSS classes when utilities work
- ❌ Never forget to configure PurgeCSS/content paths
- ❌ Never use inline styles when Tailwind utilities exist
- ❌ Never forget mobile-first responsive design
- ❌ Never use arbitrary values when a utility exists
- ❌ Never forget to use the `cn()` utility for conditional classes
- ❌ Never hardcode colors (use theme variables)
- ❌ Never forget accessibility (focus states, screen readers)
- ❌ Never use `!important` unless absolutely necessary (use higher specificity)

## Migration from v3 to v4

```bash
# Use the automated upgrade tool
npx @tailwindcss/upgrade@next
```

Key changes:
- `tailwind.config.js` → CSS `@theme` blocks
- `@tailwind` directives → `@import "tailwindcss"`
- Manual content configuration → Automatic detection
- Plugin system → CSS-first configuration
- Enhanced performance (10x faster builds)
