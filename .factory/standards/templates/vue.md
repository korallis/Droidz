# Vue.js Development Standards

## Component Patterns

### Composition API (Required for Vue 3)

```vue
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';

// ✅ Good: Composition API with TypeScript
const count = ref(0);
const doubled = computed(() => count.value * 2);

const increment = () => {
  count.value++;
};

onMounted(() => {
  console.log('Component mounted');
});
</script>

<template>
  <div>
    <p>Count: {{ count }}</p>
    <p>Doubled: {{ doubled }}</p>
    <button @click="increment">Increment</button>
  </div>
</template>
```

### Component Structure

```vue
<script setup lang="ts">
// 1. Imports
import { ref, computed } from 'vue';
import type { User } from '@/types';

// 2. Props
const props = defineProps<{
  userId: string;
}>();

// 3. Emits
const emit = defineEmits<{
  update: [user: User];
}>();

// 4. State
const user = ref<User | null>(null);

// 5. Computed
const displayName = computed(() => 
  user.value ? `${user.value.firstName} ${user.value.lastName}` : ''
);

// 6. Methods
const loadUser = async () => {
  user.value = await fetchUser(props.userId);
  emit('update', user.value);
};

// 7. Lifecycle
onMounted(() => {
  loadUser();
});
</script>
```

## State Management

### Pinia (Recommended for Vue 3)

```typescript
// stores/user.ts
import { defineStore } from 'pinia';

export const useUserStore = defineStore('user', () => {
  // State
  const user = ref<User | null>(null);
  const loading = ref(false);
  
  // Getters
  const isAuthenticated = computed(() => user.value !== null);
  
  // Actions
  async function login(email: string, password: string) {
    loading.value = true;
    try {
      user.value = await api.login(email, password);
    } finally {
      loading.value = false;
    }
  }
  
  return { user, loading, isAuthenticated, login };
});

// In component
<script setup>
import { useUserStore } from '@/stores/user';

const userStore = useUserStore();
</script>
```

## File Structure

```
src/
├── components/
│   ├── ui/              # Reusable UI components
│   ├── features/        # Feature-specific components
│   └── layouts/         # Layout components
├── composables/         # Composition functions (like React hooks)
├── stores/              # Pinia stores
├── views/               # Page components (routes)
├── router/              # Vue Router configuration
├── utils/               # Utility functions
├── types/               # TypeScript types
└── App.vue              # Root component
```

## Composables (Reusable Logic)

```typescript
// composables/useUser.ts
import { ref, watch } from 'vue';
import type { User } from '@/types';

export function useUser(userId: Ref<string>) {
  const user = ref<User | null>(null);
  const loading = ref(true);
  const error = ref<Error | null>(null);
  
  const fetchUser = async () => {
    loading.value = true;
    error.value = null;
    
    try {
      user.value = await api.getUser(userId.value);
    } catch (e) {
      error.value = e as Error;
    } finally {
      loading.value = false;
    }
  };
  
  watch(userId, fetchUser, { immediate: true });
  
  return { user, loading, error, refetch: fetchUser };
}

// Usage in component
<script setup>
const userId = ref('123');
const { user, loading, error } = useUser(userId);
</script>
```

## Reactivity Best Practices

```typescript
// ✅ Good: Proper reactive references
const count = ref(0);
const user = ref<User | null>(null);
const items = ref<Item[]>([]);

// ✅ Good: Reactive objects
const state = reactive({
  count: 0,
  user: null as User | null
});

// ❌ Bad: Destructuring loses reactivity
const { count } = state; // count is now a number, not reactive

// ✅ Good: Use toRefs for destructuring
const { count, user } = toRefs(state);
```

## Testing

```typescript
// Component.spec.ts
import { mount } from '@vue/test-utils';
import { describe, it, expect } from 'vitest';
import UserProfile from '@/components/UserProfile.vue';

describe('UserProfile', () => {
  it('renders user name', () => {
    const wrapper = mount(UserProfile, {
      props: {
        user: { name: 'John Doe' }
      }
    });
    
    expect(wrapper.text()).toContain('John Doe');
  });
  
  it('emits update event on button click', async () => {
    const wrapper = mount(UserProfile);
    await wrapper.find('button').trigger('click');
    
    expect(wrapper.emitted('update')).toBeTruthy();
  });
});
```

## Performance

- Use `v-memo` for expensive lists
- Use `v-once` for static content
- Lazy load routes and heavy components
- Use `shallowRef` for large objects that don't need deep reactivity
- Avoid unnecessary watchers

```vue
<!-- ✅ Good: v-memo for optimization -->
<div v-for="item in list" :key="item.id" v-memo="[item.selected]">
  {{ item.name }}
</div>

<!-- ✅ Good: Lazy loading routes -->
const routes = [
  {
    path: '/dashboard',
    component: () => import('./views/Dashboard.vue')
  }
];
```

## Never

- ❌ Never mutate props directly
- ❌ Never use Options API in new Vue 3 projects (use Composition API)
- ❌ Never forget `.value` when accessing refs
- ❌ Never mix reactive and non-reactive data
- ❌ Never use `any` type in TypeScript
