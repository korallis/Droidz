---
name: refactoring
description: Code works but is difficult to understand, modify, or test. Improving structure while maintaining functionality.
---

# Refactoring - Improving Code Structure Without Changing Behavior

**Use when**: Code works but is difficult to understand, modify, or test. Improving structure while maintaining functionality.

## Core Principles

1. **Behavior Preservation** - Refactoring NEVER changes what the code does, only how
2. **Small Steps** - Make tiny changes, test after each step
3. **Tests First** - Ensure comprehensive tests exist before refactoring
4. **One Thing at a Time** - Don't mix refactoring with feature additions
5. **Refactor When Adding Features** - Leave code better than you found it

## When to Refactor

### Triggers
- **Before adding a feature** - Make room for new functionality
- **During code review** - Found code smells or confusing sections
- **When fixing bugs** - Make bug impossible through better structure
- **Boy Scout Rule** - Always leave code cleaner than you found it

### Red Flags (Code Smells)
```
✗ Functions longer than ~50 lines
✗ Deeply nested conditionals (>3 levels)
✗ Duplicate code (copy-paste programming)
✗ Unclear variable names (x, temp, data)
✗ Functions with >3 parameters
✗ God classes (classes doing too much)
✗ Long parameter lists
✗ Comments explaining what code does (code should be self-documenting)
```

## Refactoring Catalog

### 1. **Extract Method/Function**

**When**: Function does too many things or has complex logic

```typescript
// Before - hard to understand
function processOrder(order) {
  // Calculate total
  let total = 0;
  for (const item of order.items) {
    total += item.price * item.quantity;
    if (item.discount) {
      total -= item.price * item.quantity * item.discount;
    }
  }
  
  // Apply taxes
  const tax = total * 0.08;
  total += tax;
  
  // Check inventory
  for (const item of order.items) {
    const stock = inventory.get(item.id);
    if (stock < item.quantity) {
      throw new Error('Insufficient stock');
    }
  }
  
  return { total, tax };
}

// After - clear responsibilities
function processOrder(order) {
  validateInventory(order.items);
  const subtotal = calculateSubtotal(order.items);
  const tax = calculateTax(subtotal);
  const total = subtotal + tax;
  return { total, tax };
}

function calculateSubtotal(items) {
  return items.reduce((sum, item) => {
    const itemTotal = item.price * item.quantity;
    const discount = item.discount ? itemTotal * item.discount : 0;
    return sum + itemTotal - discount;
  }, 0);
}

function calculateTax(amount) {
  const TAX_RATE = 0.08;
  return amount * TAX_RATE;
}

function validateInventory(items) {
  for (const item of items) {
    const stock = inventory.get(item.id);
    if (stock < item.quantity) {
      throw new InsufficientStockError(item.id, stock, item.quantity);
    }
  }
}
```

### 2. **Replace Magic Numbers with Named Constants**

```typescript
// Before - what do these numbers mean?
if (user.age >= 18 && user.age <= 65) {
  premium = basePrice * 1.0;
} else {
  premium = basePrice * 1.5;
}

setTimeout(checkStatus, 60000);

// After - self-documenting
const MIN_STANDARD_AGE = 18;
const MAX_STANDARD_AGE = 65;
const STANDARD_RATE_MULTIPLIER = 1.0;
const HIGH_RISK_RATE_MULTIPLIER = 1.5;
const STATUS_CHECK_INTERVAL_MS = 60 * 1000; // 1 minute

if (user.age >= MIN_STANDARD_AGE && user.age <= MAX_STANDARD_AGE) {
  premium = basePrice * STANDARD_RATE_MULTIPLIER;
} else {
  premium = basePrice * HIGH_RISK_RATE_MULTIPLIER;
}

setTimeout(checkStatus, STATUS_CHECK_INTERVAL_MS);
```

### 3. **Simplify Conditional Expressions**

```typescript
// Before - complex nested conditions
function getShippingCost(order) {
  if (order.items.length > 0) {
    if (order.total > 50) {
      if (order.isPremium) {
        return 0;
      } else {
        return 5;
      }
    } else {
      if (order.isPremium) {
        return 5;
      } else {
        return 10;
      }
    }
  } else {
    return 0;
  }
}

// After - guard clauses and early returns
function getShippingCost(order) {
  if (order.items.length === 0) return 0;
  if (order.isPremium && order.total > 50) return 0;
  if (order.isPremium) return 5;
  if (order.total > 50) return 5;
  return 10;
}

// Even better - strategy pattern
const SHIPPING_RATES = {
  premiumOverFifty: { cost: 0, applies: (o) => o.isPremium && o.total > 50 },
  premium: { cost: 5, applies: (o) => o.isPremium },
  standardOverFifty: { cost: 5, applies: (o) => o.total > 50 },
  standard: { cost: 10, applies: () => true }
};

function getShippingCost(order) {
  if (order.items.length === 0) return 0;
  
  for (const rate of Object.values(SHIPPING_RATES)) {
    if (rate.applies(order)) return rate.cost;
  }
}
```

### 4. **Extract Variable for Clarity**

```typescript
// Before - hard to understand
if (
  (platform === 'ios' && version >= 13) ||
  (platform === 'android' && version >= 10) ||
  (platform === 'web' && browserVersion >= 90)
) {
  enableNewUI();
}

// After - intention-revealing names
const isIosSupportedVersion = platform === 'ios' && version >= 13;
const isAndroidSupportedVersion = platform === 'android' && version >= 10;
const isWebSupportedVersion = platform === 'web' && browserVersion >= 90;
const supportsNewUI = 
  isIosSupportedVersion || 
  isAndroidSupportedVersion || 
  isWebSupportedVersion;

if (supportsNewUI) {
  enableNewUI();
}
```

### 5. **Remove Dead Code**

```typescript
// Before - cluttered with unused code
function calculatePrice(item) {
  let price = item.basePrice;
  
  // Legacy discount system (no longer used)
  // if (item.category === 'electronics') {
  //   price *= 0.9;
  // }
  
  // Apply current discount
  if (item.discount) {
    price *= (1 - item.discount);
  }
  
  // Old tax calculation
  // const oldTax = price * 0.05;
  
  // New tax calculation
  const tax = price * 0.08;
  
  return price + tax;
}

// After - clean and focused
function calculatePrice(item) {
  let price = item.basePrice;
  
  if (item.discount) {
    price *= (1 - item.discount);
  }
  
  const TAX_RATE = 0.08;
  const tax = price * TAX_RATE;
  
  return price + tax;
}
```

### 6. **Replace Nested Conditionals with Guard Clauses**

```typescript
// Before - deeply nested
function withdraw(account, amount) {
  if (account.isActive) {
    if (account.balance >= amount) {
      if (amount > 0) {
        if (!account.isFrozen) {
          account.balance -= amount;
          return { success: true, newBalance: account.balance };
        } else {
          return { success: false, error: 'Account frozen' };
        }
      } else {
        return { success: false, error: 'Invalid amount' };
      }
    } else {
      return { success: false, error: 'Insufficient funds' };
    }
  } else {
    return { success: false, error: 'Account inactive' };
  }
}

// After - guard clauses
function withdraw(account, amount) {
  if (!account.isActive) {
    return { success: false, error: 'Account inactive' };
  }
  
  if (account.isFrozen) {
    return { success: false, error: 'Account frozen' };
  }
  
  if (amount <= 0) {
    return { success: false, error: 'Invalid amount' };
  }
  
  if (account.balance < amount) {
    return { success: false, error: 'Insufficient funds' };
  }
  
  account.balance -= amount;
  return { success: true, newBalance: account.balance };
}
```

### 7. **Replace Type Code with Polymorphism**

```typescript
// Before - type checking everywhere
class Employee {
  constructor(type, salary) {
    this.type = type; // 'engineer', 'manager', 'salesperson'
    this.salary = salary;
  }
  
  calculateBonus() {
    if (this.type === 'engineer') {
      return this.salary * 0.1;
    } else if (this.type === 'manager') {
      return this.salary * 0.2;
    } else if (this.type === 'salesperson') {
      return this.salary * 0.15;
    }
  }
  
  getTitle() {
    if (this.type === 'engineer') {
      return 'Software Engineer';
    } else if (this.type === 'manager') {
      return 'Engineering Manager';
    } else if (this.type === 'salesperson') {
      return 'Sales Representative';
    }
  }
}

// After - polymorphism
class Employee {
  constructor(salary) {
    this.salary = salary;
  }
  
  calculateBonus() {
    throw new Error('Must be implemented by subclass');
  }
  
  getTitle() {
    throw new Error('Must be implemented by subclass');
  }
}

class Engineer extends Employee {
  calculateBonus() {
    return this.salary * 0.1;
  }
  
  getTitle() {
    return 'Software Engineer';
  }
}

class Manager extends Employee {
  calculateBonus() {
    return this.salary * 0.2;
  }
  
  getTitle() {
    return 'Engineering Manager';
  }
}

class Salesperson extends Employee {
  calculateBonus() {
    return this.salary * 0.15;
  }
  
  getTitle() {
    return 'Sales Representative';
  }
}
```

### 8. **Consolidate Duplicate Code**

```typescript
// Before - repeated logic
function calculateEmployeeBonus(employee) {
  let bonus = employee.salary * 0.1;
  if (employee.yearsOfService > 5) {
    bonus += 1000;
  }
  if (employee.hasTopPerformance) {
    bonus *= 1.5;
  }
  return bonus;
}

function calculateContractorBonus(contractor) {
  let bonus = contractor.salary * 0.1;
  if (contractor.yearsOfService > 5) {
    bonus += 1000;
  }
  if (contractor.hasTopPerformance) {
    bonus *= 1.5;
  }
  return bonus;
}

// After - shared logic
function calculateBonus(person) {
  let bonus = person.salary * 0.1;
  
  if (person.yearsOfService > 5) {
    bonus += 1000;
  }
  
  if (person.hasTopPerformance) {
    bonus *= 1.5;
  }
  
  return bonus;
}

// Use for both
const employeeBonus = calculateBonus(employee);
const contractorBonus = calculateBonus(contractor);
```

## Refactoring Process

### Step-by-Step Approach

```
1. Identify smell or improvement opportunity
2. Ensure tests exist and pass
3. Make ONE small refactoring change
4. Run tests - must still pass
5. Commit (optional but recommended)
6. Repeat steps 3-5 until satisfied
7. Final test run
8. Code review
```

### Example Process

```typescript
// Original code
function process(data) {
  let result = [];
  for (let i = 0; i < data.length; i++) {
    if (data[i].status === 'active' && data[i].age >= 18) {
      result.push({
        id: data[i].id,
        name: data[i].name,
        email: data[i].email
      });
    }
  }
  return result;
}

// Step 1: Extract condition
function isEligible(item) {
  return item.status === 'active' && item.age >= 18;
}

function process(data) {
  let result = [];
  for (let i = 0; i < data.length; i++) {
    if (isEligible(data[i])) {
      result.push({
        id: data[i].id,
        name: data[i].name,
        email: data[i].email
      });
    }
  }
  return result;
}
// Test ✓

// Step 2: Replace loop with array method
function process(data) {
  let result = [];
  data.forEach(item => {
    if (isEligible(item)) {
      result.push({
        id: item.id,
        name: item.name,
        email: item.email
      });
    }
  });
  return result;
}
// Test ✓

// Step 3: Extract transformation
function transformToUser(item) {
  return {
    id: item.id,
    name: item.name,
    email: item.email
  };
}

function process(data) {
  let result = [];
  data.forEach(item => {
    if (isEligible(item)) {
      result.push(transformToUser(item));
    }
  });
  return result;
}
// Test ✓

// Step 4: Use filter and map
function process(data) {
  return data
    .filter(isEligible)
    .map(transformToUser);
}
// Test ✓

// Final result - clear, functional, testable
```

## Common Pitfalls

### ❌ Refactoring Without Tests
```
If tests don't exist, write them first!
Otherwise, you can't verify behavior is preserved.
```

### ❌ Big Bang Refactoring
```
Don't rewrite everything at once.
Small, incremental changes are safer and easier to review.
```

### ❌ Mixing Refactoring with Features
```
Separate commits:
- Commit 1: Refactor (no behavior change)
- Commit 2: Add feature (uses refactored code)
```

### ❌ Over-Engineering
```
Don't add complexity "for future needs"
Refactor when needed, not speculatively.
YAGNI: You Aren't Gonna Need It
```

## Tools

### IDE Refactoring Tools
```
✓ Rename (safe rename across all files)
✓ Extract method/function
✓ Extract variable
✓ Inline variable/function
✓ Change signature
✓ Move to file/module
```

### Static Analysis
```bash
# JavaScript/TypeScript
eslint --fix
prettier --write

# Python
pylint
black

# Find code smells
# PMD, SonarQube, CodeClimate
```

## Resources

- [Refactoring by Martin Fowler](https://refactoring.com/)
- [Refactoring Catalog](https://refactoring.guru/refactoring/catalog)
- [Clean Code by Robert Martin](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)
- [Working Effectively with Legacy Code by Michael Feathers](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)

---

**Remember**: Refactoring is continuous improvement. Every time you touch code, leave it a little cleaner. Small, frequent refactorings are better than rare, massive rewrites.
