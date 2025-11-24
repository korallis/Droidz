---
name: nextjs-server-components
description: Building Next.js 13+ apps, optimizing component rendering, managing server/client boundaries. Use when working with nextjs server components in your development workflow.
---

# Next.js Server Components - React Server Components Patterns

## When to use this skill

- Building Next.js 13+ apps, optimizing component rendering, managing server/client boundaries.
- When working on related tasks or features
- During development that requires this expertise

**Use when**: Building Next.js 13+ apps, optimizing component rendering, managing server/client boundaries.

## Key Concepts

Server Components (default in App Router):
- Run only on server
- Can directly access databases/APIs
- Zero client JavaScript
- Support async/await

Client Components ('use client'):
- Interactive features
- Browser APIs
- React hooks (useState, useEffect, etc.)

## Composition Pattern

```typescript
// ✅ Server Component fetches data
// app/page.tsx
import { ClientComponent } from './ClientComponent';

export default async function Page() {
  const data = await fetchData(); // Server-side
  
  return (
    <div>
      <h1>Server Rendered: {data.title}</h1>
      <ClientComponent initialData={data} />
    </div>
  );
}

// ✅ Client Component handles interactivity
// app/ClientComponent.tsx
'use client';

export function ClientComponent({ initialData }) {
  const [count, setCount] = useState(0);
  
  return <button onClick={() => setCount(count + 1)}>{count}</button>;
}
```

## Pass Server Components as Children

```typescript
// ✅ Client Component with Server Component children
'use client';

export function ClientLayout({ children }: { children: React.ReactNode }) {
  const [isOpen, setIsOpen] = useState(false);
  
  return (
    <div>
      <button onClick={() => setIsOpen(!isOpen)}>Toggle</button>
      {isOpen && children}
    </div>
  );
}

// Usage - children can be Server Components!
<ClientLayout>
  <ServerDataComponent /> {/* Stays on server */}
</ClientLayout>
```

## When to Use Client Components

Only use 'use client' when you need:
- useState, useEffect, useContext
- Browser APIs (localStorage, window)
- Event handlers (onClick, onChange)
- Custom hooks
- Third-party libraries that use React hooks

## Resources
- [Server Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components)
- [Client Components](https://nextjs.org/docs/app/building-your-application/rendering/client-components)

---

**Remember**: Keep components server-side by default. Only add 'use client' when necessary for interactivity.
