# Next.js 14/15 Development Standards

## App Router Architecture (Required for Next.js 13+)

### Server Components (Default)

```tsx
// app/dashboard/page.tsx
import { api } from '@/lib/api';

// ✅ Good: Server Component (async, data fetching at build/request time)
export default async function DashboardPage() {
  const data = await api.getDashboardData();
  
  return (
    <div>
      <h1>{data.title}</h1>
      <DashboardClient initialData={data} />
    </div>
  );
}

// ❌ Bad: Don't use hooks or browser APIs in Server Components
export default function BadDashboardPage() {
  const [data, setData] = useState(); // ERROR: Can't use hooks
  useEffect(() => {}); // ERROR: Can't use useEffect
  return <div>...</div>;
}
```

### Client Components

```tsx
// app/components/interactive-button.tsx
'use client';

import { useState } from 'react';

// ✅ Good: Client Component for interactivity
export function InteractiveButton() {
  const [count, setCount] = useState(0);
  
  return (
    <button onClick={() => setCount(count + 1)}>
      Clicked {count} times
    </button>
  );
}
```

## Server Actions (Preferred for Mutations)

```tsx
// app/actions.ts
'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string;
  const content = formData.get('content') as string;
  
  // Validate
  if (!title || !content) {
    return { error: 'Title and content are required' };
  }
  
  // Mutate data
  await db.posts.create({ title, content });
  
  // Revalidate cache
  revalidatePath('/posts');
  
  // Redirect
  redirect('/posts');
}

// ✅ Good: Form component using Server Action
// app/components/post-form.tsx
'use client';

import { useActionState } from 'react';
import { createPost } from '@/app/actions';

export function PostForm() {
  const [state, formAction, isPending] = useActionState(createPost, {});
  
  return (
    <form action={formAction}>
      <input type="text" name="title" required />
      <textarea name="content" required />
      <button type="submit" disabled={isPending}>
        {isPending ? 'Creating...' : 'Create Post'}
      </button>
      {state?.error && <p className="error">{state.error}</p>}
    </form>
  );
}
```

## Data Fetching Patterns

### Parallel Data Fetching

```tsx
// ✅ Good: Fetch data in parallel
export default async function Page() {
  // Initiate both requests in parallel
  const userPromise = fetch('/api/user').then(r => r.json());
  const postsPromise = fetch('/api/posts').then(r => r.json());
  
  // Wait for both
  const [user, posts] = await Promise.all([userPromise, postsPromise]);
  
  return <div>{/* Use user and posts */}</div>;
}
```

### Streaming with Suspense

```tsx
// ✅ Good: Stream content with Suspense boundaries
import { Suspense } from 'react';

export default function Page() {
  return (
    <div>
      <h1>My Dashboard</h1>
      <Suspense fallback={<LoadingSkeleton />}>
        <SlowComponent />
      </Suspense>
      <Suspense fallback={<div>Loading charts...</div>}>
        <ChartComponent />
      </Suspense>
    </div>
  );
}

async function SlowComponent() {
  const data = await fetchSlowData();
  return <div>{data.content}</div>;
}
```

## File Structure

```
app/
├── (auth)/              # Route group (doesn't affect URL)
│   ├── login/
│   │   └── page.tsx
│   └── register/
│       └── page.tsx
├── (marketing)/         # Another route group
│   ├── about/
│   │   └── page.tsx
│   └── contact/
│       └── page.tsx
├── dashboard/
│   ├── layout.tsx       # Shared layout
│   ├── page.tsx         # /dashboard route
│   ├── loading.tsx      # Loading UI
│   ├── error.tsx        # Error UI
│   └── [id]/            # Dynamic route
│       └── page.tsx     # /dashboard/[id]
├── api/
│   └── posts/
│       └── route.ts     # API route handler
├── actions.ts           # Server Actions
├── layout.tsx           # Root layout
└── page.tsx             # Home page (/)
```

## Routing Best Practices

### Dynamic Routes

```tsx
// app/posts/[slug]/page.tsx
interface PageProps {
  params: Promise<{ slug: string }>;
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>;
}

// ✅ Good: Await params in Next.js 15+
export default async function PostPage({ params, searchParams }: PageProps) {
  const { slug } = await params;
  const { query } = await searchParams;
  
  const post = await getPost(slug);
  return <article>{post.content}</article>;
}

// Generate static params at build time
export async function generateStaticParams() {
  const posts = await getPosts();
  return posts.map((post) => ({ slug: post.slug }));
}
```

### Parallel and Intercepting Routes

```tsx
// app/photos/@modal/(..)photo/[id]/page.tsx
// Intercepts /photo/[id] when navigated from /photos

export default async function PhotoModal({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const photo = await getPhoto(id);
  
  return (
    <div className="modal">
      <img src={photo.url} alt={photo.title} />
    </div>
  );
}
```

## Caching and Revalidation

```tsx
// ✅ Good: Configure caching per request
export async function fetchPosts() {
  const res = await fetch('https://api.example.com/posts', {
    next: { 
      revalidate: 3600, // Revalidate every hour
      tags: ['posts']   // Tag for on-demand revalidation
    }
  });
  return res.json();
}

// On-demand revalidation
// app/actions.ts
'use server';

import { revalidateTag, revalidatePath } from 'next/cache';

export async function updatePost(id: string) {
  await db.posts.update(id);
  
  // Revalidate specific tag
  revalidateTag('posts');
  
  // Or revalidate specific path
  revalidatePath('/posts');
}

// ✅ Good: Disable caching when needed
export async function fetchDynamicData() {
  const res = await fetch('https://api.example.com/data', {
    cache: 'no-store' // Always fetch fresh data
  });
  return res.json();
}
```

## Middleware

```tsx
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  // Authentication check
  const token = request.cookies.get('token');
  
  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }
  
  // Add custom header
  const response = NextResponse.next();
  response.headers.set('x-custom-header', 'value');
  
  return response;
}

export const config = {
  matcher: [
    // Match all request paths except static files
    '/((?!api|_next/static|_next/image|favicon.ico).*)',
  ],
};
```

## Metadata and SEO

```tsx
// app/layout.tsx
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: {
    default: 'My App',
    template: '%s | My App', // "Page Title | My App"
  },
  description: 'Welcome to my app',
  openGraph: {
    title: 'My App',
    description: 'Welcome to my app',
    images: ['/og-image.jpg'],
  },
};

// app/posts/[slug]/page.tsx
export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> {
  const { slug } = await params;
  const post = await getPost(slug);
  
  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      images: [post.image],
    },
  };
}
```

## Image Optimization

```tsx
import Image from 'next/image';

// ✅ Good: Use Next.js Image component
export function ProductImage({ src, alt }: { src: string; alt: string }) {
  return (
    <Image
      src={src}
      alt={alt}
      width={600}
      height={400}
      sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
      priority={false} // Set true for above-the-fold images
      placeholder="blur"
      blurDataURL="data:image/..." // Or use static import
    />
  );
}

// ❌ Bad: Don't use regular <img> tag
export function BadImage() {
  return <img src="/photo.jpg" alt="Photo" />; // No optimization!
}
```

## Loading States and Errors

```tsx
// app/dashboard/loading.tsx
export default function Loading() {
  return <div>Loading dashboard...</div>;
}

// app/dashboard/error.tsx
'use client';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <p>{error.message}</p>
      <button onClick={() => reset()}>Try again</button>
    </div>
  );
}

// app/dashboard/not-found.tsx
export default function NotFound() {
  return (
    <div>
      <h2>Dashboard Not Found</h2>
      <p>The dashboard you're looking for doesn't exist.</p>
    </div>
  );
}
```

## Performance Optimization

```tsx
// ✅ Good: Use dynamic imports for code splitting
import dynamic from 'next/dynamic';

const HeavyComponent = dynamic(() => import('./heavy-component'), {
  loading: () => <p>Loading...</p>,
  ssr: false, // Disable SSR for this component if needed
});

// ✅ Good: Preload critical resources
import { preload } from 'react-dom';

function Component() {
  preload('/api/data', { as: 'fetch' });
  return <div>...</div>;
}
```

## Security Best Practices

```tsx
// ✅ Good: Validate input in Server Actions
'use server';

import { z } from 'zod';

const userSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

export async function createUser(formData: FormData) {
  const validated = userSchema.safeParse({
    email: formData.get('email'),
    password: formData.get('password'),
  });
  
  if (!validated.success) {
    return { error: validated.error.errors };
  }
  
  // Safe to use validated.data
  await db.users.create(validated.data);
}

// ✅ Good: Use environment variables properly
// Only NEXT_PUBLIC_* variables are exposed to the browser
const apiUrl = process.env.NEXT_PUBLIC_API_URL; // Client-safe
const secretKey = process.env.SECRET_KEY; // Server-only
```

## Testing

```tsx
// __tests__/page.test.tsx
import { render, screen } from '@testing-library/react';
import Page from '@/app/page';

describe('Page', () => {
  it('renders correctly', () => {
    render(<Page />);
    expect(screen.getByText('Welcome')).toBeInTheDocument();
  });
});

// For Server Components, test the rendered output
import { use } from 'react';

describe('ServerComponent', () => {
  it('renders data correctly', async () => {
    const Component = await ServerComponent();
    const { container } = render(Component);
    expect(container).toHaveTextContent('Expected content');
  });
});
```

## Never

- ❌ Never use `'use client'` at the root layout unless absolutely necessary
- ❌ Never fetch data in Client Components when you can use Server Components
- ❌ Never use API routes for simple data fetching (use Server Components instead)
- ❌ Never forget to await `params` and `searchParams` in Next.js 15+
- ❌ Never use outdated Pages Router patterns in App Router projects
- ❌ Never forget to revalidate cache after mutations
- ❌ Never expose sensitive data to client components
- ❌ Never use `getServerSideProps`, `getStaticProps` (these are Pages Router only)
