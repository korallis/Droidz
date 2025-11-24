# Next.js App Router - Modern React Framework Patterns

**Use when**: Building Next.js 13+ applications with App Router, implementing Server Components, or optimizing React Server Components patterns.

## Core Concepts

1. **Server Components by Default** - Components are server-rendered unless marked with 'use client'
2. **File-based Routing** - `/app` directory structure defines routes
3. **Streaming & Suspense** - Progressive rendering for better UX
4. **Data Fetching** - Server-side with automatic caching
5. **Layouts & Templates** - Shared UI that persists across routes

## App Router Structure

```
app/
├── layout.tsx          # Root layout (required)
├── page.tsx            # Home page (/)
├── loading.tsx         # Loading UI
├── error.tsx           # Error UI
├── not-found.tsx       # 404 UI
├── dashboard/
│   ├── layout.tsx      # Dashboard layout
│   ├── page.tsx        # /dashboard
│   └── settings/
│       └── page.tsx    # /dashboard/settings
└── api/
    └── users/
        └── route.ts    # API endpoint /api/users
```

## Server vs Client Components

```typescript
// ✅ Server Component (default - no 'use client')
// app/page.tsx
import { db } from '@/lib/db';

export default async function Page() {
  // Fetch data on server
  const users = await db.user.findMany();
  
  return (
    <div>
      <h1>Users</h1>
      {users.map(user => <UserCard key={user.id} user={user} />)}
    </div>
  );
}

// ✅ Client Component (interactive features)
// app/components/Counter.tsx
'use client';

import { useState } from 'react';

export function Counter() {
  const [count, setCount] = useState(0);
  
  return (
    <button onClick={() => setCount(count + 1)}>
      Count: {count}
    </button>
  );
}

// ✅ Composition: Server Component with Client Component children
// app/page.tsx
import { Counter } from './components/Counter';

export default async function Page() {
  const data = await fetchData(); // Server-side
  
  return (
    <div>
      <h1>Server Data: {data}</h1>
      <Counter /> {/* Client interactive component */}
    </div>
  );
}
```

## Data Fetching

```typescript
// ✅ Fetch with caching (default: 'force-cache')
async function getUsers() {
  const res = await fetch('https://api.example.com/users', {
    cache: 'force-cache' // Cached until revalidated
  });
  return res.json();
}

// ✅ Revalidate every 60 seconds
async function getUsers() {
  const res = await fetch('https://api.example.com/users', {
    next: { revalidate: 60 }
  });
  return res.json();
}

// ✅ No caching (always fresh)
async function getUsers() {
  const res = await fetch('https://api.example.com/users', {
    cache: 'no-store'
  });
  return res.json();
}

// ✅ Database query (Prisma)
import { db } from '@/lib/db';

async function getUser(id: string) {
  return await db.user.findUnique({ where: { id } });
}
```

## Dynamic Routes

```typescript
// app/posts/[id]/page.tsx
interface PageProps {
  params: { id: string };
  searchParams: { [key: string]: string | string[] | undefined };
}

export default async function PostPage({ params }: PageProps) {
  const post = await db.post.findUnique({ where: { id: params.id } });
  
  return <div>{post.title}</div>;
}

// Generate static paths at build time
export async function generateStaticParams() {
  const posts = await db.post.findMany();
  return posts.map((post) => ({ id: post.id }));
}

// Generate metadata
export async function generateMetadata({ params }: PageProps) {
  const post = await db.post.findUnique({ where: { id: params.id } });
  
  return {
    title: post.title,
    description: post.excerpt
  };
}
```

## Layouts

```typescript
// app/layout.tsx (Root Layout - Required)
export default function RootLayout({
  children
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <Header />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  );
}

// app/dashboard/layout.tsx (Nested Layout)
export default function DashboardLayout({
  children
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="dashboard">
      <Sidebar />
      <div className="content">{children}</div>
    </div>
  );
}
```

## Loading & Error States

```typescript
// app/dashboard/loading.tsx
export default function Loading() {
  return <Spinner />;
}

// app/dashboard/error.tsx
'use client';

export default function Error({
  error,
  reset
}: {
  error: Error;
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

## Streaming with Suspense

```typescript
import { Suspense } from 'react';

export default function Page() {
  return (
    <div>
      <h1>Dashboard</h1>
      
      {/* This loads immediately */}
      <QuickStats />
      
      {/* This streams in when ready */}
      <Suspense fallback={<Skeleton />}>
        <SlowComponent />
      </Suspense>
    </div>
  );
}

async function SlowComponent() {
  const data = await slowDatabaseQuery();
  return <div>{data}</div>;
}
```

## Route Handlers (API Routes)

```typescript
// app/api/users/route.ts
import { NextResponse } from 'next/server';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const page = searchParams.get('page') || '1';
  
  const users = await db.user.findMany({
    skip: (parseInt(page) - 1) * 20,
    take: 20
  });
  
  return NextResponse.json({ users });
}

export async function POST(request: Request) {
  const body = await request.json();
  
  const user = await db.user.create({
    data: body
  });
  
  return NextResponse.json(user, { status: 201 });
}

// Dynamic route: app/api/users/[id]/route.ts
export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  const user = await db.user.findUnique({ where: { id: params.id } });
  
  if (!user) {
    return NextResponse.json({ error: 'Not found' }, { status: 404 });
  }
  
  return NextResponse.json(user);
}
```

## Best Practices

- **Minimize Client Components** - Use 'use client' only when needed (interactivity, hooks)
- **Fetch Data on Server** - Reduces client bundle, improves security
- **Streaming** - Use Suspense for progressive rendering
- **Metadata** - Generate SEO-friendly metadata per route
- **Parallel Routes** - Use `@folder` convention for parallel rendering
- **Route Groups** - Use `(folder)` for organization without affecting URL

## Resources
- [Next.js App Router Docs](https://nextjs.org/docs/app)
- [Server Components Explained](https://nextjs.org/docs/app/building-your-application/rendering/server-components)
- [Data Fetching Patterns](https://nextjs.org/docs/app/building-your-application/data-fetching)

---

**Remember**: App Router is server-first. Embrace Server Components, use Client Components sparingly, and leverage streaming for better UX.
