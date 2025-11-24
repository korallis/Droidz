# React Server Actions - Form Handling

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
