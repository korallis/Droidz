# Supabase Best Practices

## Core Principles

1. **Row Level Security (RLS)** - Always enable RLS on tables with user data
2. **Realtime** - Use Realtime for live data updates, not polling
3. **Edge Functions** - Server-side logic in TypeScript Deno functions
4. **Storage** - Use Supabase Storage for files, not base64 in database
5. **Auth** - Leverage built-in auth, don't roll your own

## Database Schema & RLS

### ✅ Good: Table with RLS Policies
```sql
-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can view all profiles
CREATE POLICY "Profiles are viewable by everyone"
ON profiles FOR SELECT
USING (true);

-- Users can insert their own profile
CREATE POLICY "Users can insert their own profile"
ON profiles FOR INSERT
WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update their own profile"
ON profiles FOR UPDATE
USING (auth.uid() = id);

-- Example table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  avatar_url TEXT,
  bio TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### ✅ Good: Complex RLS with JOIN
```sql
-- Posts table
CREATE TABLE posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  author_id UUID REFERENCES auth.users(id) NOT NULL,
  title TEXT NOT NULL,
  content TEXT,
  published BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Anyone can view published posts
CREATE POLICY "Published posts are publicly visible"
ON posts FOR SELECT
USING (published = true);

-- Users can view their own drafts
CREATE POLICY "Users can view their own posts"
ON posts FOR SELECT
USING (auth.uid() = author_id);

-- Users can create their own posts
CREATE POLICY "Users can create posts"
ON posts FOR INSERT
WITH CHECK (auth.uid() = author_id);

-- Users can update their own posts
CREATE POLICY "Users can update own posts"
ON posts FOR UPDATE
USING (auth.uid() = author_id);
```

## TypeScript Client Usage

### ✅ Good: Client Setup
```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js';
import type { Database } from '@/types/database';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey);

// For Server Components (Next.js)
import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';

export function createClient() {
  const cookieStore = cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value;
        },
      },
    }
  );
}
```

### ✅ Good: Type-Safe Queries
```typescript
// Generate types: npx supabase gen types typescript --project-id YOUR_PROJECT_ID > types/database.ts

import { supabase } from '@/lib/supabase';

// Query with type safety
const { data, error } = await supabase
  .from('profiles')
  .select('id, username, avatar_url')
  .eq('id', userId)
  .single();

if (error) {
  console.error('Error fetching profile:', error);
  return null;
}

// data is fully typed!
return data;
```

### ✅ Good: Insert with Type Safety
```typescript
const { data, error } = await supabase
  .from('posts')
  .insert({
    title: 'My Post',
    content: 'Hello world',
    author_id: user.id,
    published: false
  })
  .select()
  .single();

if (error) {
  throw new Error(`Failed to create post: ${error.message}`);
}

return data;
```

### ✅ Good: Update with RLS
```typescript
// RLS ensures user can only update their own posts
const { data, error } = await supabase
  .from('posts')
  .update({ title: 'Updated Title', published: true })
  .eq('id', postId)
  .select()
  .single();

if (error) {
  if (error.code === 'PGRST116') {
    throw new Error('Post not found or unauthorized');
  }
  throw error;
}

return data;
```

## Realtime Subscriptions

### ✅ Good: Subscribe to Table Changes
```typescript
'use client';

import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import type { Database } from '@/types/database';

type Post = Database['public']['Tables']['posts']['Row'];

export function RealtimePosts() {
  const [posts, setPosts] = useState<Post[]>([]);

  useEffect(() => {
    // Fetch initial data
    const fetchPosts = async () => {
      const { data } = await supabase
        .from('posts')
        .select('*')
        .eq('published', true)
        .order('created_at', { ascending: false });
      
      setPosts(data || []);
    };

    fetchPosts();

    // Subscribe to changes
    const channel = supabase
      .channel('posts-changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'posts',
          filter: 'published=eq.true'
        },
        (payload) => {
          if (payload.eventType === 'INSERT') {
            setPosts(prev => [payload.new as Post, ...prev]);
          } else if (payload.eventType === 'UPDATE') {
            setPosts(prev => prev.map(post => 
              post.id === payload.new.id ? payload.new as Post : post
            ));
          } else if (payload.eventType === 'DELETE') {
            setPosts(prev => prev.filter(post => post.id !== payload.old.id));
          }
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, []);

  return (
    <div>
      {posts.map(post => (
        <article key={post.id}>
          <h2>{post.title}</h2>
          <p>{post.content}</p>
        </article>
      ))}
    </div>
  );
}
```

### ✅ Good: Broadcast (Presence)
```typescript
const channel = supabase.channel('room-1');

// Track presence
channel
  .on('presence', { event: 'sync' }, () => {
    const state = channel.presenceState();
    console.log('Online users:', state);
  })
  .on('presence', { event: 'join' }, ({ key, newPresences }) => {
    console.log('User joined:', newPresences);
  })
  .on('presence', { event: 'leave' }, ({ key, leftPresences }) => {
    console.log('User left:', leftPresences);
  })
  .subscribe(async (status) => {
    if (status === 'SUBSCRIBED') {
      await channel.track({ user_id: user.id, online_at: new Date().toISOString() });
    }
  });
```

## Authentication

### ✅ Good: Email/Password Signup
```typescript
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'secure-password-123',
  options: {
    data: {
      username: 'johndoe',
      age: 25
    },
    emailRedirectTo: 'https://example.com/welcome'
  }
});

if (error) {
  throw new Error(error.message);
}

// User is created, email confirmation sent
```

### ✅ Good: OAuth (Google, GitHub, etc.)
```typescript
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: {
    redirectTo: 'https://example.com/auth/callback',
    queryParams: {
      access_type: 'offline',
      prompt: 'consent'
    }
  }
});
```

### ✅ Good: Get Current User
```typescript
const { data: { user }, error } = await supabase.auth.getUser();

if (error || !user) {
  // Not authenticated
  redirect('/login');
}

// User is authenticated
return user;
```

### ✅ Good: Auth State Changes
```typescript
'use client';

import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import type { User } from '@supabase/supabase-js';

export function useUser() {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user ?? null);
    });

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        setUser(session?.user ?? null);
      }
    );

    return () => subscription.unsubscribe();
  }, []);

  return user;
}
```

## Storage

### ✅ Good: Upload File
```typescript
const file = event.target.files[0];
const fileExt = file.name.split('.').pop();
const fileName = `${user.id}/${Math.random()}.${fileExt}`;

const { data, error } = await supabase.storage
  .from('avatars')
  .upload(fileName, file, {
    cacheControl: '3600',
    upsert: false
  });

if (error) {
  throw new Error(`Upload failed: ${error.message}`);
}

// Get public URL
const { data: { publicUrl } } = supabase.storage
  .from('avatars')
  .getPublicUrl(data.path);

return publicUrl;
```

### ✅ Good: Storage Policies
```sql
-- Enable RLS on storage.objects
CREATE POLICY "Avatar images are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

-- Users can upload their own avatar
CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can update their own avatar
CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

## Edge Functions

### ✅ Good: Deno Edge Function
```typescript
// supabase/functions/send-email/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Get user from auth header
    const authHeader = req.headers.get('Authorization')!;
    const { data: { user }, error: authError } = await supabase.auth.getUser(
      authHeader.replace('Bearer ', '')
    );

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const { email, subject, message } = await req.json();

    // Send email (using Resend, SendGrid, etc.)
    // await sendEmail({ to: email, subject, message });

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
```

## Database Functions & Triggers

### ✅ Good: Updated_at Trigger
```sql
-- Function to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger on profiles table
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### ✅ Good: Database Function
```sql
CREATE OR REPLACE FUNCTION get_user_posts(user_id UUID)
RETURNS TABLE (
  id UUID,
  title TEXT,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT p.id, p.title, p.created_at
  FROM posts p
  WHERE p.author_id = user_id
    AND p.published = true
  ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Call from TypeScript
const { data, error } = await supabase.rpc('get_user_posts', { user_id: userId });
```

## Error Handling

### ✅ Good: Comprehensive Error Handling
```typescript
async function createPost(title: string, content: string) {
  const { data, error } = await supabase
    .from('posts')
    .insert({ title, content, author_id: user.id })
    .select()
    .single();

  if (error) {
    // Check specific error codes
    if (error.code === '23505') {
      // Unique constraint violation
      throw new Error('A post with this title already exists');
    }
    
    if (error.code === '23503') {
      // Foreign key violation
      throw new Error('Invalid author');
    }

    if (error.code === 'PGRST116') {
      // Row not found or RLS policy violation
      throw new Error('Unauthorized or not found');
    }

    // Generic error
    throw new Error(`Database error: ${error.message}`);
  }

  return data;
}
```

**ALWAYS use Row Level Security, leverage Realtime for live updates, use type-safe clients, and follow Supabase best practices for auth, storage, and edge functions.**
