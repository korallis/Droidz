---
name: react-server-actions
description: Implementing forms, mutations in Next.js App Router. Use when implementing form handling in Next.js 14+, creating server mutations, or building progressive enhancement patterns with React Server Actions.
---

# React Server Actions - Form Handling

## When to use this skill

- Implementing forms, mutations in Next.js App Router.
- When working on related tasks or features
- During development that requires this expertise

**Use when**: Implementing forms, mutations in Next.js App Router.

## Server Action
\`\`\`typescript
'use server';

export async function createPost(formData: FormData) {
  const title = formData.get('title');
  await db.post.create({ data: { title } });
  revalidatePath('/posts');
}
\`\`\`

## Resources
- [Server Actions](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations)
