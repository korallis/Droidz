---
name: playwright-automation
description: E2E testing, browser automation, web scraping.. Use when playwright automation. Use when working with playwright automation in your development workflow.
---

# Playwright Automation - Browser Testing

## When to use this skill

- E2E testing, browser automation, web scraping.
- When working on related tasks or features
- During development that requires this expertise

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
