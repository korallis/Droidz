# Next.js 15 App Router Best Practices

## Core Principles

1. **Server Components by Default** - Use Client Components only when needed
2. **Server Actions** - Handle mutations with type-safe server functions
3. **Data Fetching** - Fetch data in Server Components, not useEffect
4. **Streaming** - Use Suspense boundaries for progressive rendering
5. **Caching** - Understand Next.js caching layers (Request, Data, Full Route)

## App Router Structure

```
app/
├── layout.tsx              # Root layout (Server Component)
├── page.tsx                # Home page (Server Component)
├── loading.tsx             # Loading UI (shows while page loads)
├── error.tsx               # Error boundary
├── not-found.tsx           # 404 page
├── (auth)/                 # Route group (doesn't affect URL)
│   ├── login/
│   │   └── page.tsx
│   └── signup/
│       └── page.tsx
├── dashboard/
│   ├── layout.tsx          # Nested layout
│   ├── page.tsx
│   └── [id]/               # Dynamic route
│       └── page.tsx
└── api/
    └── webhooks/
        └── route.ts        # API Route Handler
```

## Server Components vs Client Components

### ✅ Good: Server Components (Default)
```tsx
// app/posts/page.tsx - Server Component by default
import { db } from '@/lib/db';

export default async function PostsPage() {
  // Fetch data directly in Server Component
  const posts = await db.post.findMany({
    orderBy: { createdAt: 'desc' },
    take: 10
  });

  return (
    <div>
      <h1>Latest Posts</h1>
      {posts.map(post => (
        <article key={post.id}>
          <h2>{post.title}</h2>
          <p>{post.excerpt}</p>
        </article>
      ))}
    </div>
  );
}
```

### ✅ Good: Client Component (When Needed)
```tsx
// components/search-form.tsx
'use client'; // Only mark as client when you need interactivity

import { useState } from 'react';
import { useRouter } from 'next/navigation';

export function SearchForm() {
  const [query, setQuery] = useState('');
  const router = useRouter();

  return (
    <form onSubmit={(e) => {
      e.preventDefault();
      router.push(`/search?q=${encodeURIComponent(query)}`);
    }}>
      <input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search..."
      />
      <button type="submit">Search</button>
    </form>
  );
}
```

### ❌ Bad: Client Component for Data Fetching
```tsx
'use client';

import { useEffect, useState } from 'react';

// Don't do this - defeats Server Components benefits
export default function PostsPage() {
  const [posts, setPosts] = useState([]);

  useEffect(() => {
    fetch('/api/posts')
      .then(res => res.json())
      .then(setPosts);
  }, []);

  // ...
}
```

## Server Actions

### ✅ Good: Server Action with Form
```tsx
// app/posts/create/page.tsx
import { createPost } from './actions';

export default function CreatePostPage() {
  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit">Create Post</button>
    </form>
  );
}

// app/posts/create/actions.ts
'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { z } from 'zod';
import { db } from '@/lib/db';

const createPostSchema = z.object({
  title: z.string().min(1).max(255),
  content: z.string().min(1)
});

export async function createPost(formData: FormData) {
  const parsed = createPostSchema.safeParse({
    title: formData.get('title'),
    content: formData.get('content')
  });

  if (!parsed.success) {
    return { error: 'Invalid input' };
  }

  const post = await db.post.create({
    data: parsed.data
  });

  revalidatePath('/posts');
  redirect(`/posts/${post.id}`);
}
```

### ✅ Good: Progressive Enhancement with useTransition
```tsx
'use client';

import { useTransition } from 'react';
import { createPost } from './actions';

export function CreatePostForm() {
  const [isPending, startTransition] = useTransition();

  async function handleSubmit(formData: FormData) {
    startTransition(async () => {
      await createPost(formData);
    });
  }

  return (
    <form action={handleSubmit}>
      <input name="title" disabled={isPending} />
      <textarea name="content" disabled={isPending} />
      <button type="submit" disabled={isPending}>
        {isPending ? 'Creating...' : 'Create Post'}
      </button>
    </form>
  );
}
```

### ✅ Good: Server Action with Optimistic Updates
```tsx
'use client';

import { useOptimistic } from 'react';
import { likePost } from './actions';

export function LikeButton({ postId, initialLikes }: { postId: string; initialLikes: number }) {
  const [optimisticLikes, addOptimisticLike] = useOptimistic(
    initialLikes,
    (state) => state + 1
  );

  return (
    <form action={async () => {
      addOptimisticLike(null);
      await likePost(postId);
    }}>
      <button type="submit">
        ❤️ {optimisticLikes}
      </button>
    </form>
  );
}
```

## Data Fetching Patterns

### ✅ Good: Parallel Data Fetching
```tsx
// app/dashboard/page.tsx
export default async function DashboardPage() {
  // Fetch in parallel
  const [user, posts, stats] = await Promise.all([
    getUser(),
    getPosts(),
    getStats()
  ]);

  return (
    <div>
      <UserProfile user={user} />
      <PostsList posts={posts} />
      <StatsWidget stats={stats} />
    </div>
  );
}
```

### ✅ Good: Sequential Data Fetching (When Needed)
```tsx
export default async function UserPostsPage({ params }: { params: { id: string } }) {
  // Fetch user first
  const user = await getUser(params.id);
  
  // Then fetch posts for that user
  const posts = await getUserPosts(user.id);

  return (
    <div>
      <UserHeader user={user} />
      <PostsList posts={posts} />
    </div>
  );
}
```

### ✅ Good: Streaming with Suspense
```tsx
// app/dashboard/page.tsx
import { Suspense } from 'react';

export default function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>
      
      {/* Show immediately */}
      <QuickStats />
      
      {/* Stream when ready */}
      <Suspense fallback={<PostsSkeleton />}>
        <RecentPosts />
      </Suspense>
      
      <Suspense fallback={<ActivitySkeleton />}>
        <RecentActivity />
      </Suspense>
    </div>
  );
}

// This component streams independently
async function RecentPosts() {
  const posts = await getPosts(); // Can be slow
  return <PostsList posts={posts} />;
}
```

## Route Handlers (API Routes)

### ✅ Good: GET Route with Params
```tsx
// app/api/posts/[id]/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const post = await db.post.findUnique({
    where: { id: params.id }
  });

  if (!post) {
    return NextResponse.json(
      { error: 'Post not found' },
      { status: 404 }
    );
  }

  return NextResponse.json(post);
}
```

### ✅ Good: POST Route with Validation
```tsx
// app/api/posts/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { db } from '@/lib/db';

const createPostSchema = z.object({
  title: z.string().min(1).max(255),
  content: z.string().min(1)
});

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const parsed = createPostSchema.parse(body);

    const post = await db.post.create({
      data: parsed
    });

    return NextResponse.json(post, { status: 201 });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation failed', details: error.errors },
        { status: 400 }
      );
    }

    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
```

## Middleware

### ✅ Good: Auth Middleware
```tsx
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const token = request.cookies.get('auth_token');
  const { pathname } = request.nextUrl;

  // Redirect to login if accessing protected route without token
  if (!token && pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  // Redirect to dashboard if accessing auth pages with token
  if (token && (pathname === '/login' || pathname === '/signup')) {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/dashboard/:path*', '/login', '/signup']
};
```

## Metadata & SEO

### ✅ Good: Static Metadata
```tsx
// app/about/page.tsx
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'About Us',
  description: 'Learn more about our company',
  openGraph: {
    title: 'About Us',
    description: 'Learn more about our company',
    images: ['/og-about.jpg']
  }
};

export default function AboutPage() {
  return <div>About Us</div>;
}
```

### ✅ Good: Dynamic Metadata
```tsx
// app/posts/[id]/page.tsx
import type { Metadata } from 'next';

type Props = {
  params: { id: string };
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const post = await getPost(params.id);

  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      title: post.title,
      description: post.excerpt,
      images: [post.coverImage]
    }
  };
}

export default async function PostPage({ params }: Props) {
  const post = await getPost(params.id);
  return <Article post={post} />;
}
```

## Caching & Revalidation

### ✅ Good: Revalidate on Demand
```tsx
'use server';

import { revalidatePath, revalidateTag } from 'next/cache';

export async function createPost(data: CreatePostInput) {
  const post = await db.post.create({ data });
  
  // Revalidate specific path
  revalidatePath('/posts');
  revalidatePath(`/posts/${post.id}`);
  
  return post;
}

// With tags
export async function getPosts() {
  const posts = await fetch('https://api.example.com/posts', {
    next: { tags: ['posts'] }
  });
  return posts.json();
}

export async function updatePost(id: string, data: UpdatePostInput) {
  const post = await db.post.update({ where: { id }, data });
  
  // Revalidate all requests tagged with 'posts'
  revalidateTag('posts');
  
  return post;
}
```

### ✅ Good: Time-based Revalidation
```tsx
// app/posts/page.tsx
export const revalidate = 3600; // Revalidate every hour

export default async function PostsPage() {
  const posts = await getPosts();
  return <PostsList posts={posts} />;
}

// Or per-fetch
async function getPosts() {
  const res = await fetch('https://api.example.com/posts', {
    next: { revalidate: 3600 } // Revalidate this request every hour
  });
  return res.json();
}
```

## Loading States & Error Handling

### ✅ Good: Loading UI
```tsx
// app/dashboard/loading.tsx
export default function DashboardLoading() {
  return (
    <div className="space-y-4">
      <div className="h-8 w-64 bg-gray-200 animate-pulse rounded" />
      <div className="h-64 bg-gray-200 animate-pulse rounded" />
    </div>
  );
}
```

### ✅ Good: Error Boundary
```tsx
// app/dashboard/error.tsx
'use client';

import { useEffect } from 'react';

export default function DashboardError({
  error,
  reset
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error('Dashboard error:', error);
  }, [error]);

  return (
    <div>
      <h2>Something went wrong!</h2>
      <p>{error.message}</p>
      <button onClick={() => reset()}>Try again</button>
    </div>
  );
}
```

## Environment Variables

### ✅ Good: Type-Safe Env Vars
```tsx
// env.ts
import { z } from 'zod';

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  NEXT_PUBLIC_APP_URL: z.string().url(),
  NEXT_PUBLIC_API_KEY: z.string().min(1),
  SECRET_KEY: z.string().min(32)
});

export const env = envSchema.parse({
  DATABASE_URL: process.env.DATABASE_URL,
  NEXT_PUBLIC_APP_URL: process.env.NEXT_PUBLIC_APP_URL,
  NEXT_PUBLIC_API_KEY: process.env.NEXT_PUBLIC_API_KEY,
  SECRET_KEY: process.env.SECRET_KEY
});

// Usage
import { env } from '@/env';

const dbUrl = env.DATABASE_URL; // Type-safe!
```

**ALWAYS follow Next.js 15 App Router patterns. Use Server Components by default, Server Actions for mutations, and proper streaming with Suspense boundaries.**
