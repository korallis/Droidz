---
name: supabase
description: Use when user mentions Supabase, Row Level Security, realtime, or Supabase auth. Expert in Supabase including RLS policies, realtime subscriptions, auth, storage, and edge functions.
category: backend
---

# Supabase Best Practices

**Official Supabase guidelines - RLS, Realtime, Auth, Storage, Edge Functions**

## Core Principles

1. **ALWAYS Enable RLS** - Row Level Security on all tables in `public` schema
2. **Auth-Based Policies** - Use `auth.uid()` and `auth.jwt()` for user context
3. **Realtime Authorization** - Control Broadcast/Presence with RLS on `realtime.messages`
4. **Server-Side Auth** - Use SSR helpers for Next.js server components
5. **Storage Security** - Protect files with RLS policies on `storage.objects`
6. **Edge Functions** - Deploy Deno functions globally with Auth context

## Row Level Security (RLS) - Complete Guide

### ✅ Good: Enable RLS on Tables
```sql
-- ALWAYS enable RLS on tables in public schema
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for CRUD operations
CREATE POLICY "Users can view their own profile"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can insert their own profile"
  ON public.profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own profile"
  ON public.profiles
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);
```

### ✅ Good: Public Read, Authenticated Write
```sql
-- Anyone can view, only authenticated users can create
CREATE POLICY "Public profiles are viewable by everyone"
  ON public.profiles
  FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Users can create profiles"
  ON public.profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);
```

### ✅ Good: RLS with Relationships
```sql
-- Posts table with user_id foreign key
CREATE POLICY "Users can view posts in their groups"
  ON public.posts
  FOR SELECT
  TO authenticated
  USING (
    group_id IN (
      SELECT group_id
      FROM group_members
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create posts in their groups"
  ON public.posts
  FOR INSERT
  TO authenticated
  WITH CHECK (
    group_id IN (
      SELECT group_id
      FROM group_members
      WHERE user_id = auth.uid()
    )
  );
```

### ✅ Good: Using auth.jwt() for Custom Claims
```sql
-- Check user role from JWT
CREATE POLICY "Admins can view all users"
  ON public.users
  FOR SELECT
  TO authenticated
  USING (
    (auth.jwt() ->> 'role') = 'admin'
    OR auth.uid() = id
  );

-- Check team membership from app_metadata
CREATE POLICY "Team members can view team data"
  ON public.projects
  FOR SELECT
  TO authenticated
  USING (
    team_id = ANY(
      SELECT jsonb_array_elements_text(
        auth.jwt() -> 'app_metadata' -> 'teams'
      )::uuid
    )
  );
```

### ✅ Good: Explicit NULL Checks
```sql
-- ALWAYS check for NULL to prevent silent failures
CREATE POLICY "Authenticated users can view own data"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (
    auth.uid() IS NOT NULL
    AND auth.uid() = user_id
  );
```

### ❌ Bad: RLS Anti-patterns
```sql
-- ❌ WRONG - No RLS enabled (data exposed!)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY,
  email TEXT
);
-- Missing: ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- ❌ WRONG - Using user_metadata for authorization
CREATE POLICY "Check user metadata"
  ON public.profiles
  USING (
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  );
-- user_metadata can be modified by users!

-- ❌ WRONG - Not checking for NULL
CREATE POLICY "Users own data"
  ON public.profiles
  USING (auth.uid() = user_id);
-- If user is not authenticated, auth.uid() returns NULL
-- NULL = user_id is always false, silently fails
```

## RLS Performance Optimization

### ✅ Good: Add Indexes for RLS
```sql
-- Index columns used in policies
CREATE INDEX idx_profiles_user_id ON public.profiles(user_id);
CREATE INDEX idx_posts_group_id ON public.posts(group_id);
CREATE INDEX idx_group_members_user_id ON public.group_members(user_id);
CREATE INDEX idx_group_members_group_id ON public.group_members(group_id);
```

### ✅ Good: Use SELECT for Function Caching
```sql
-- Wrap auth functions in SELECT for caching
CREATE POLICY "Cached auth check"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);
-- Postgres caches (SELECT auth.uid()) per statement
```

### ✅ Good: Security Definer Functions
```sql
-- Create security definer function to bypass RLS for performance
CREATE OR REPLACE FUNCTION has_group_access(group_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM group_members
    WHERE user_id = auth.uid()
      AND group_members.group_id = $1
  );
END;
$$;

-- Use in policy
CREATE POLICY "Users can view group posts"
  ON public.posts
  FOR SELECT
  TO authenticated
  USING ((SELECT has_group_access(group_id)));
```

### ✅ Good: Minimize JOINs in Policies
```sql
-- ❌ Slow - JOIN in policy
CREATE POLICY "Slow policy"
  ON public.posts
  USING (
    auth.uid() IN (
      SELECT user_id
      FROM group_members
      WHERE group_members.group_id = posts.group_id
    )
  );

-- ✅ Fast - Fetch into array
CREATE POLICY "Fast policy"
  ON public.posts
  USING (
    group_id IN (
      SELECT group_id
      FROM group_members
      WHERE user_id = auth.uid()
    )
  );
```

## Realtime - Broadcast and Presence

### ✅ Good: Basic Realtime Setup
```typescript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

// Subscribe to database changes
const channel = supabase
  .channel('db-changes')
  .on(
    'postgres_changes',
    {
      event: '*',
      schema: 'public',
      table: 'posts'
    },
    (payload) => {
      console.log('Change received!', payload)
    }
  )
  .subscribe()
```

### ✅ Good: Realtime Broadcast (No RLS)
```typescript
// Public channel - no authorization
const channel = supabase.channel('room-1')

// Send broadcast
channel.send({
  type: 'broadcast',
  event: 'message',
  payload: { text: 'Hello world' }
})

// Receive broadcast
channel.on('broadcast', { event: 'message' }, (payload) => {
  console.log(payload)
})

await channel.subscribe()
```

### ✅ Good: Realtime Broadcast with Authorization
```sql
-- Enable RLS on realtime.messages table
ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read broadcasts on specific topic
CREATE POLICY "Users can receive broadcasts in room"
  ON realtime.messages
  FOR SELECT
  TO authenticated
  USING (
    realtime.topic() = 'room-1'
    AND extension = 'broadcast'
    AND EXISTS (
      SELECT 1 FROM rooms_users
      WHERE user_id = auth.uid()
        AND topic = 'room-1'
    )
  );

-- Allow authenticated users to send broadcasts
CREATE POLICY "Users can send broadcasts in room"
  ON realtime.messages
  FOR INSERT
  TO authenticated
  WITH CHECK (
    realtime.topic() = 'room-1'
    AND extension = 'broadcast'
    AND EXISTS (
      SELECT 1 FROM rooms_users
      WHERE user_id = auth.uid()
        AND topic = 'room-1'
    )
  );
```

```typescript
// Client - join private channel
const channel = supabase.channel('room-1', {
  config: { private: true }  // Enable RLS
})

channel.on('broadcast', { event: 'message' }, (payload) => {
  console.log(payload)
})

await channel.subscribe()
```

### ✅ Good: Realtime Presence
```typescript
const channel = supabase.channel('room-1')

// Track presence
await channel.subscribe(async (status) => {
  if (status === 'SUBSCRIBED') {
    await channel.track({
      user_id: user.id,
      online_at: new Date().toISOString()
    })
  }
})

// Listen to presence changes
channel.on('presence', { event: 'sync' }, () => {
  const state = channel.presenceState()
  console.log('Online users:', state)
})

channel.on('presence', { event: 'join' }, ({ newPresences }) => {
  console.log('User joined:', newPresences)
})

channel.on('presence', { event: 'leave' }, ({ leftPresences }) => {
  console.log('User left:', leftPresences)
})
```

### ✅ Good: Presence with Authorization
```sql
-- RLS policy for presence
CREATE POLICY "Users can track presence in room"
  ON realtime.messages
  FOR INSERT
  TO authenticated
  WITH CHECK (
    realtime.topic() = 'room-1'
    AND extension = 'presence'
    AND EXISTS (
      SELECT 1 FROM rooms_users
      WHERE user_id = auth.uid()
        AND topic = 'room-1'
    )
  );

CREATE POLICY "Users can listen to presence in room"
  ON realtime.messages
  FOR SELECT
  TO authenticated
  USING (
    realtime.topic() = 'room-1'
    AND extension = 'presence'
    AND EXISTS (
      SELECT 1 FROM rooms_users
      WHERE user_id = auth.uid()
        AND topic = 'room-1'
    )
  );
```

### ✅ Good: Postgres Changes with Filters
```typescript
// Subscribe to specific filters
const channel = supabase
  .channel('posts-changes')
  .on(
    'postgres_changes',
    {
      event: 'INSERT',
      schema: 'public',
      table: 'posts',
      filter: 'user_id=eq.abc123'  // Only posts by specific user
    },
    (payload) => {
      console.log('New post!', payload)
    }
  )
  .subscribe()
```

## Authentication

### ✅ Good: Email/Password Signup
```typescript
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'secure-password',
  options: {
    data: {
      first_name: 'John',
      last_name: 'Doe'
    },
    emailRedirectTo: 'https://example.com/confirm'
  }
})
```

### ✅ Good: Email/Password Login
```typescript
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'secure-password'
})

if (error) {
  console.error('Login failed:', error.message)
  return
}

const user = data.user
const session = data.session
```

### ✅ Good: OAuth Login
```typescript
// Sign in with OAuth provider
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: {
    redirectTo: 'https://example.com/auth/callback',
    scopes: 'email profile'
  }
})
```

### ✅ Good: Magic Link Login
```typescript
const { data, error } = await supabase.auth.signInWithOtp({
  email: 'user@example.com',
  options: {
    emailRedirectTo: 'https://example.com/auth/confirm'
  }
})
```

### ✅ Good: Get Session
```typescript
const { data: { session } } = await supabase.auth.getSession()

if (session) {
  const user = session.user
  const accessToken = session.access_token
}
```

### ✅ Good: Get User
```typescript
const { data: { user } } = await supabase.auth.getUser()

if (user) {
  console.log('User ID:', user.id)
  console.log('Email:', user.email)
  console.log('Metadata:', user.user_metadata)
}
```

### ✅ Good: Sign Out
```typescript
const { error } = await supabase.auth.signOut()
```

### ✅ Good: Update User
```typescript
const { data, error } = await supabase.auth.updateUser({
  data: {
    first_name: 'Jane',
    last_name: 'Smith'
  }
})
```

### ✅ Good: Password Reset
```typescript
// Request password reset
const { data, error } = await supabase.auth.resetPasswordForEmail(
  'user@example.com',
  {
    redirectTo: 'https://example.com/reset-password'
  }
)

// Update password (after clicking reset link)
const { data, error } = await supabase.auth.updateUser({
  password: 'new-secure-password'
})
```

## Server-Side Auth (Next.js)

### ✅ Good: Next.js App Router Setup
```typescript
// utils/supabase/server.ts
import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function createClient() {
  const cookieStore = await cookies()

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value
        },
        set(name: string, value: string, options: CookieOptions) {
          cookieStore.set({ name, value, ...options })
        },
        remove(name: string, options: CookieOptions) {
          cookieStore.set({ name, value: '', ...options })
        },
      },
    }
  )
}
```

### ✅ Good: Server Component with Auth
```typescript
// app/dashboard/page.tsx
import { createClient } from '@/utils/supabase/server'
import { redirect } from 'next/navigation'

export default async function DashboardPage() {
  const supabase = await createClient()

  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    redirect('/login')
  }

  // Fetch user-specific data (RLS automatically applied)
  const { data: posts } = await supabase
    .from('posts')
    .select('*')
    .eq('user_id', user.id)

  return (
    <div>
      <h1>Welcome {user.email}</h1>
      {/* render posts */}
    </div>
  )
}
```

### ✅ Good: Client Component with Auth
```typescript
// utils/supabase/client.ts
import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}

// components/LoginButton.tsx
'use client'

import { createClient } from '@/utils/supabase/client'

export default function LoginButton() {
  const supabase = createClient()

  const handleLogin = async () => {
    await supabase.auth.signInWithPassword({
      email: 'user@example.com',
      password: 'password'
    })
  }

  return <button onClick={handleLogin}>Login</button>
}
```

### ✅ Good: Middleware for Auth
```typescript
// middleware.ts
import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({
    request: {
      headers: request.headers,
    },
  })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return request.cookies.get(name)?.value
        },
        set(name: string, value: string, options: CookieOptions) {
          request.cookies.set({ name, value, ...options })
          response = NextResponse.next({
            request: {
              headers: request.headers,
            },
          })
          response.cookies.set({ name, value, ...options })
        },
        remove(name: string, options: CookieOptions) {
          request.cookies.set({ name, value: '', ...options })
          response = NextResponse.next({
            request: {
              headers: request.headers,
            },
          })
          response.cookies.set({ name, value: '', ...options })
        },
      },
    }
  )

  await supabase.auth.getUser()

  return response
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
```

### ✅ Good: Auth Callback Route
```typescript
// app/auth/callback/route.ts
import { createClient } from '@/utils/supabase/server'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const requestUrl = new URL(request.url)
  const code = requestUrl.searchParams.get('code')

  if (code) {
    const supabase = await createClient()
    await supabase.auth.exchangeCodeForSession(code)
  }

  return NextResponse.redirect(requestUrl.origin)
}
```

## Storage

### ✅ Good: Upload File
```typescript
const { data, error } = await supabase.storage
  .from('avatars')
  .upload(`public/${userId}/avatar.png`, file, {
    cacheControl: '3600',
    upsert: true
  })
```

### ✅ Good: Download File
```typescript
const { data, error } = await supabase.storage
  .from('avatars')
  .download(`public/${userId}/avatar.png`)
```

### ✅ Good: Get Public URL
```typescript
const { data } = supabase.storage
  .from('avatars')
  .getPublicUrl(`public/${userId}/avatar.png`)

const publicUrl = data.publicUrl
```

### ✅ Good: Create Signed URL (Private Files)
```typescript
const { data, error } = await supabase.storage
  .from('private-files')
  .createSignedUrl(`user/${userId}/document.pdf`, 3600)  // 1 hour

const signedUrl = data.signedUrl
```

### ✅ Good: List Files
```typescript
const { data, error } = await supabase.storage
  .from('avatars')
  .list('public', {
    limit: 100,
    offset: 0,
    sortBy: { column: 'name', order: 'asc' }
  })
```

### ✅ Good: Delete Files
```typescript
const { data, error } = await supabase.storage
  .from('avatars')
  .remove([`public/${userId}/avatar.png`])
```

### ✅ Good: Storage RLS Policies
```sql
-- Allow users to upload their own avatars
CREATE POLICY "Users can upload own avatar"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = 'public'
    AND (storage.foldername(name))[2] = auth.uid()::text
  );

-- Allow users to view all avatars
CREATE POLICY "Anyone can view avatars"
  ON storage.objects
  FOR SELECT
  TO public
  USING (bucket_id = 'avatars');

-- Allow users to update their own avatar
CREATE POLICY "Users can update own avatar"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[2] = auth.uid()::text
  )
  WITH CHECK (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[2] = auth.uid()::text
  );

-- Allow users to delete their own avatar
CREATE POLICY "Users can delete own avatar"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[2] = auth.uid()::text
  );
```

## Edge Functions

### ✅ Good: Basic Edge Function
```typescript
// supabase/functions/hello/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const { name } = await req.json()

  return new Response(
    JSON.stringify({ message: `Hello ${name}!` }),
    { headers: { 'Content-Type': 'application/json' } }
  )
})
```

### ✅ Good: Edge Function with Auth
```typescript
// supabase/functions/protected/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    {
      global: {
        headers: { Authorization: req.headers.get('Authorization')! },
      },
    }
  )

  // Get user from JWT
  const {
    data: { user },
  } = await supabaseClient.auth.getUser()

  if (!user) {
    return new Response(
      JSON.stringify({ error: 'Unauthorized' }),
      { status: 401 }
    )
  }

  return new Response(
    JSON.stringify({ message: `Hello ${user.email}!` }),
    { headers: { 'Content-Type': 'application/json' } }
  )
})
```

### ✅ Good: Edge Function with Database Access
```typescript
// supabase/functions/get-posts/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''  // Service role for full access
  )

  const { data: posts, error } = await supabaseClient
    .from('posts')
    .select('*')
    .limit(10)

  if (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500 }
    )
  }

  return new Response(
    JSON.stringify({ posts }),
    { headers: { 'Content-Type': 'application/json' } }
  )
})
```

### ✅ Good: Deploy Edge Function
```bash
# Deploy single function
supabase functions deploy hello

# Deploy with secrets
supabase secrets set MY_SECRET_KEY=value
supabase functions deploy hello

# Invoke function
curl -L -X POST 'https://project-ref.supabase.co/functions/v1/hello' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Functions"}'
```

## Database Best Practices

### ✅ Good: Typed Queries with TypeScript
```typescript
// Generate types
// npx supabase gen types typescript --project-id YOUR_PROJECT_ID > types/database.types.ts

import { Database } from '@/types/database.types'

const supabase = createClient<Database>(url, key)

// Fully typed!
const { data } = await supabase
  .from('posts')
  .select('id, title, user_id')
  .eq('user_id', userId)
```

### ✅ Good: Transactions with RPC
```sql
-- Create RPC function for transaction
CREATE OR REPLACE FUNCTION transfer_balance(
  from_user_id UUID,
  to_user_id UUID,
  amount NUMERIC
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  -- Deduct from sender
  UPDATE accounts
  SET balance = balance - amount
  WHERE user_id = from_user_id;

  -- Add to receiver
  UPDATE accounts
  SET balance = balance + amount
  WHERE user_id = to_user_id;
END;
$$;
```

```typescript
// Call RPC function
const { data, error } = await supabase.rpc('transfer_balance', {
  from_user_id: 'user-1',
  to_user_id: 'user-2',
  amount: 100
})
```

### ✅ Good: Pagination
```typescript
const PAGE_SIZE = 20

const { data, error, count } = await supabase
  .from('posts')
  .select('*', { count: 'exact' })
  .range(page * PAGE_SIZE, (page + 1) * PAGE_SIZE - 1)
  .order('created_at', { ascending: false })

const totalPages = Math.ceil((count ?? 0) / PAGE_SIZE)
```

### ✅ Good: Full-Text Search
```sql
-- Create text search index
CREATE INDEX posts_title_content_idx
  ON posts
  USING gin(to_tsvector('english', title || ' ' || content));
```

```typescript
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .textSearch('title', 'hello world', {
    type: 'websearch',
    config: 'english'
  })
```

**CRITICAL: ALWAYS enable RLS on public tables, use (SELECT auth.uid()) for performance, protect Realtime channels with RLS policies, use SSR helpers for Next.js, and secure Storage with RLS on storage.objects.**
