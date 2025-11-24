---
name: e2e-testing
description: Verifying complete user flows, testing integrations, validating critical paths, or ensuring features work in production-like environments. Use when writing tests, setting up test frameworks, ensuring code coverage, or implementing testing strategies.
---

# End-to-End Testing - Testing Full User Workflows

## When to use this skill

- Verifying complete user flows, testing integrations, validating critical paths, or ensuring features work in production-like environments.
- When working on related tasks or features
- During development that requires this expertise

**Use when**: Verifying complete user flows, testing integrations, validating critical paths, or ensuring features work in production-like environments.

## Core Principles

1. **Test User Journeys, Not Implementation** - Focus on what users do
2. **Test Critical Paths First** - Happy paths and key revenue flows
3. **Stable Selectors** - Use data-testid, not brittle CSS selectors
4. **Independent Tests** - No shared state between tests
5. **Fast Feedback** - Parallel execution, smart retries

## Playwright (Recommended)

### 1. **Basic Setup**

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure'
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] }
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] }
    },
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] }
    }
  ],

  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI
  }
});
```

### 2. **Writing Tests**

```typescript
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test('user can sign up', async ({ page }) => {
    await page.goto('/signup');
    
    // Fill form
    await page.getByLabel('Email').fill('user@example.com');
    await page.getByLabel('Password').fill('SecurePass123!');
    await page.getByLabel('Confirm Password').fill('SecurePass123!');
    
    // Submit
    await page.getByRole('button', { name: 'Sign Up' }).click();
    
    // Assert success
    await expect(page).toHaveURL('/dashboard');
    await expect(page.getByText('Welcome')).toBeVisible();
  });

  test('shows error for invalid email', async ({ page }) => {
    await page.goto('/signup');
    
    await page.getByLabel('Email').fill('invalid-email');
    await page.getByLabel('Password').fill('password123');
    await page.getByRole('button', { name: 'Sign Up' }).click();
    
    // Error message appears
    await expect(page.getByText('Invalid email format')).toBeVisible();
    
    // Still on signup page
    await expect(page).toHaveURL('/signup');
  });

  test('user can log in', async ({ page }) => {
    await page.goto('/login');
    
    await page.getByLabel('Email').fill('existing@example.com');
    await page.getByLabel('Password').fill('password123');
    await page.getByRole('button', { name: 'Log In' }).click();
    
    await expect(page).toHaveURL('/dashboard');
  });
});
```

### 3. **Page Object Model**

```typescript
// ✅ Encapsulate page interactions
// e2e/pages/LoginPage.ts
import { Page } from '@playwright/test';

export class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.page.getByLabel('Email').fill(email);
    await this.page.getByLabel('Password').fill(password);
    await this.page.getByRole('button', { name: 'Log In' }).click();
  }

  async getErrorMessage() {
    return this.page.getByRole('alert').textContent();
  }
}

// Usage in tests
test('successful login', async ({ page }) => {
  const loginPage = new LoginPage(page);
  
  await loginPage.goto();
  await loginPage.login('user@example.com', 'password123');
  
  await expect(page).toHaveURL('/dashboard');
});
```

### 4. **Fixtures for Setup/Teardown**

```typescript
// ✅ Reusable test fixtures
// e2e/fixtures.ts
import { test as base } from '@playwright/test';

type Fixtures = {
  authenticatedPage: Page;
};

export const test = base.extend<Fixtures>({
  authenticatedPage: async ({ page }, use) => {
    // Setup: Log in before test
    await page.goto('/login');
    await page.getByLabel('Email').fill('test@example.com');
    await page.getByLabel('Password').fill('password123');
    await page.getByRole('button', { name: 'Log In' }).click();
    await page.waitForURL('/dashboard');
    
    // Run test
    await use(page);
    
    // Teardown: Log out after test
    await page.getByRole('button', { name: 'Log Out' }).click();
  }
});

// Usage
test('create post as authenticated user', async ({ authenticatedPage }) => {
  await authenticatedPage.goto('/posts/new');
  await authenticatedPage.getByLabel('Title').fill('My Post');
  await authenticatedPage.getByRole('button', { name: 'Publish' }).click();
  
  await expect(authenticatedPage.getByText('Post published')).toBeVisible();
});
```

### 5. **Waiting Strategies**

```typescript
// ✅ Wait for conditions, not arbitrary timeouts
test('search functionality', async ({ page }) => {
  await page.goto('/search');
  
  // Type in search
  await page.getByPlaceholder('Search...').fill('playwright');
  
  // ❌ Bad - arbitrary timeout
  await page.waitForTimeout(2000);
  
  // ✅ Good - wait for specific condition
  await page.waitForLoadState('networkidle');
  
  // ✅ Better - wait for specific element
  await page.waitForSelector('[data-testid="search-results"]');
  
  // ✅ Best - implicit wait with assertion
  await expect(page.getByTestId('search-results')).toBeVisible();
  
  const results = page.getByTestId('result-item');
  await expect(results).toHaveCount(10);
});

// ✅ Wait for API calls
test('data loads correctly', async ({ page }) => {
  // Wait for specific API call
  const responsePromise = page.waitForResponse(
    (response) => response.url().includes('/api/users') && response.status() === 200
  );
  
  await page.goto('/users');
  
  const response = await responsePromise;
  const data = await response.json();
  
  expect(data.users).toHaveLength(5);
});
```

### 6. **Testing Forms & Interactions**

```typescript
test('checkout flow', async ({ page }) => {
  await page.goto('/cart');
  
  // Click checkout button
  await page.getByRole('button', { name: 'Checkout' }).click();
  
  // Fill shipping info
  await page.getByLabel('Full Name').fill('John Doe');
  await page.getByLabel('Address').fill('123 Main St');
  await page.getByLabel('City').fill('San Francisco');
  await page.getByLabel('State').selectOption('CA');
  await page.getByLabel('ZIP Code').fill('94102');
  
  await page.getByRole('button', { name: 'Continue' }).click();
  
  // Fill payment info (use test card)
  await page.frameLocator('iframe[title="Payment"]')
    .getByPlaceholder('Card number')
    .fill('4242424242424242');
  
  await page.frameLocator('iframe[title="Payment"]')
    .getByPlaceholder('MM / YY')
    .fill('12/25');
  
  await page.frameLocator('iframe[title="Payment"]')
    .getByPlaceholder('CVC')
    .fill('123');
  
  // Submit order
  await page.getByRole('button', { name: 'Place Order' }).click();
  
  // Verify success
  await expect(page.getByText('Order confirmed')).toBeVisible();
  await expect(page).toHaveURL(/\/orders\/\d+/);
});
```

### 7. **Testing File Uploads**

```typescript
test('upload profile picture', async ({ page }) => {
  await page.goto('/profile/edit');
  
  // Upload file
  const fileInput = page.getByLabel('Profile Picture');
  await fileInput.setInputFiles('fixtures/avatar.png');
  
  // Wait for upload to complete
  await expect(page.getByText('Upload complete')).toBeVisible();
  
  await page.getByRole('button', { name: 'Save' }).click();
  
  // Verify new avatar shows
  const avatar = page.getByRole('img', { name: 'Profile picture' });
  await expect(avatar).toHaveAttribute('src', /avatar\.png/);
});
```

### 8. **Visual Regression Testing**

```typescript
test('homepage looks correct', async ({ page }) => {
  await page.goto('/');
  
  // Take screenshot and compare
  await expect(page).toHaveScreenshot('homepage.png');
});

test('button hover state', async ({ page }) => {
  await page.goto('/');
  
  const button = page.getByRole('button', { name: 'Get Started' });
  await button.hover();
  
  await expect(button).toHaveScreenshot('button-hover.png');
});
```

## Cypress Alternative

### 1. **Cypress Setup**

```typescript
// cypress/e2e/auth.cy.ts
describe('Authentication', () => {
  beforeEach(() => {
    cy.visit('/login');
  });

  it('allows user to log in', () => {
    cy.get('[data-testid="email"]').type('user@example.com');
    cy.get('[data-testid="password"]').type('password123');
    cy.get('[data-testid="submit"]').click();
    
    cy.url().should('include', '/dashboard');
    cy.contains('Welcome back').should('be.visible');
  });

  it('shows error for wrong password', () => {
    cy.get('[data-testid="email"]').type('user@example.com');
    cy.get('[data-testid="password"]').type('wrongpassword');
    cy.get('[data-testid="submit"]').click();
    
    cy.contains('Invalid credentials').should('be.visible');
  });
});
```

### 2. **Cypress Commands**

```typescript
// cypress/support/commands.ts
declare global {
  namespace Cypress {
    interface Chainable {
      login(email: string, password: string): Chainable<void>;
      createPost(title: string, content: string): Chainable<void>;
    }
  }
}

Cypress.Commands.add('login', (email, password) => {
  cy.visit('/login');
  cy.get('[data-testid="email"]').type(email);
  cy.get('[data-testid="password"]').type(password);
  cy.get('[data-testid="submit"]').click();
  cy.url().should('include', '/dashboard');
});

Cypress.Commands.add('createPost', (title, content) => {
  cy.visit('/posts/new');
  cy.get('[data-testid="title"]').type(title);
  cy.get('[data-testid="content"]').type(content);
  cy.get('[data-testid="publish"]').click();
});

// Usage
it('creates a post', () => {
  cy.login('user@example.com', 'password123');
  cy.createPost('My Post', 'Post content here');
  cy.contains('Post published').should('be.visible');
});
```

## Best Practices

### 1. **Use Stable Selectors**

```typescript
// ❌ Brittle - breaks when styling changes
await page.locator('.btn-primary.large').click();
await page.locator('div > div > button:nth-child(2)').click();

// ✅ Semantic - uses accessible roles
await page.getByRole('button', { name: 'Submit' }).click();
await page.getByRole('textbox', { name: 'Email' }).fill('test@example.com');

// ✅ Test IDs - explicit test hooks
await page.getByTestId('submit-button').click();
await page.getByTestId('email-input').fill('test@example.com');

// In your component:
<button data-testid="submit-button">Submit</button>
<input data-testid="email-input" type="email" />
```

### 2. **Independent Tests**

```typescript
// ❌ Tests depend on each other
test('create user', async ({ page }) => {
  // Creates user with ID stored globally
  globalUserId = await createUser();
});

test('update user', async ({ page }) => {
  // Fails if previous test didn't run
  await updateUser(globalUserId);
});

// ✅ Each test is self-contained
test('update user', async ({ page }) => {
  // Create user for this test only
  const user = await createTestUser();
  
  await page.goto(`/users/${user.id}/edit`);
  await page.getByLabel('Name').fill('New Name');
  await page.getByRole('button', { name: 'Save' }).click();
  
  await expect(page.getByText('Updated successfully')).toBeVisible();
  
  // Cleanup
  await deleteTestUser(user.id);
});
```

### 3. **Test Data Management**

```typescript
// ✅ Factory functions for test data
export function createTestUser(overrides = {}) {
  return {
    email: `test-${Date.now()}@example.com`,
    password: 'password123',
    name: 'Test User',
    ...overrides
  };
}

// Usage
test('create multiple users', async ({ page }) => {
  const user1 = createTestUser({ name: 'Alice' });
  const user2 = createTestUser({ name: 'Bob' });
  
  // Each gets unique email due to timestamp
});

// ✅ Database seeding
test.beforeEach(async ({ page }) => {
  // Seed database with test data
  await db.users.deleteMany();
  await db.users.createMany([
    createTestUser({ email: 'alice@test.com' }),
    createTestUser({ email: 'bob@test.com' })
  ]);
});
```

### 4. **Mocking External Services**

```typescript
// ✅ Mock API responses
test('handles API error', async ({ page }) => {
  // Intercept and mock API call
  await page.route('**/api/users', (route) => {
    route.fulfill({
      status: 500,
      body: JSON.stringify({ error: 'Server error' })
    });
  });
  
  await page.goto('/users');
  
  await expect(page.getByText('Failed to load users')).toBeVisible();
});

// ✅ Mock successful response
test('displays user list', async ({ page }) => {
  await page.route('**/api/users', (route) => {
    route.fulfill({
      status: 200,
      body: JSON.stringify({
        users: [
          { id: 1, name: 'Alice' },
          { id: 2, name: 'Bob' }
        ]
      })
    });
  });
  
  await page.goto('/users');
  
  await expect(page.getByText('Alice')).toBeVisible();
  await expect(page.getByText('Bob')).toBeVisible();
});
```

## E2E Testing Checklist

```
Test Coverage:
□ Critical user paths tested (signup, login, purchase)
□ Happy paths covered
□ Error scenarios tested
□ Edge cases included
□ Mobile viewport tested

Test Quality:
□ Stable selectors (data-testid, roles)
□ No arbitrary timeouts
□ No test interdependencies
□ Proper waits for async operations
□ Clear test descriptions

Performance:
□ Tests run in parallel
□ Fast test data creation
□ Minimal unnecessary waits
□ Strategic use of mocks
□ Cleanup after tests

CI/CD:
□ Tests run on every PR
□ Failures block merges
□ Screenshots on failure
□ Test reports generated
□ Flaky tests identified and fixed
```

## Resources

- [Playwright Documentation](https://playwright.dev/)
- [Cypress Documentation](https://www.cypress.io/)
- [Testing Best Practices](https://testingjavascript.com/)

---

**Remember**: E2E tests verify what users actually experience. Keep them focused on critical paths, stable, and fast.
