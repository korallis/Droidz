---
name: playwright-automation
description: E2E testing, browser automation, web scraping.
---

# Playwright Automation - Browser Testing

**Use when**: E2E testing, browser automation, web scraping.

## Basic Test
\`\`\`typescript
import { test, expect } from '@playwright/test';

test('homepage', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading')).toBeVisible();
});
\`\`\`

## Resources
- [Playwright](https://playwright.dev/)
