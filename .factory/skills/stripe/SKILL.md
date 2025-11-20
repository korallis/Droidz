---
name: stripe
description: Auto-activates when user mentions Stripe, payments, subscriptions, or payment processing. Expert in Stripe integration including checkout, subscriptions, webhooks, and security best practices.
category: payments
---

# Stripe Payment Integration

Expert-level knowledge of Stripe payment processing, subscriptions, webhooks, and security best practices.

## Setup & Configuration

### Installation

```bash
bun add stripe
bun add -D @stripe/stripe-js
```

### Environment Variables

Always use environment variables for API keys. Never hardcode credentials.

```bash
# .env.local
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Production
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

### Server-Side SDK Initialization

```typescript
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-11-20.acacia',
  typescript: true,
});
```

### Client-Side Initialization

```typescript
import { loadStripe } from '@stripe/stripe-js';

const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!);
```

### ✅ Good: Secure Configuration

```typescript
// lib/stripe.ts
import Stripe from 'stripe';

if (!process.env.STRIPE_SECRET_KEY) {
  throw new Error('STRIPE_SECRET_KEY is not set');
}

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: '2024-11-20.acacia',
  typescript: true,
  appInfo: {
    name: 'my-app',
    version: '1.0.0',
  },
});
```

### ❌ Bad: Hardcoded Keys

```typescript
// NEVER DO THIS
const stripe = new Stripe('sk_live_abc123...', {
  apiVersion: '2024-11-20.acacia',
});
```

### API Key Types

1. **Secret Key** (`sk_`): Server-side only, full API access
2. **Publishable Key** (`pk_`): Client-side safe, limited access
3. **Restricted Key**: Limited permissions, specific operations
4. **Test Keys** (`test`): Development and testing
5. **Live Keys** (`live`): Production environment

### Key Rotation Best Practices

```typescript
// Store multiple keys for rotation
const stripe = new Stripe(
  process.env.STRIPE_SECRET_KEY_CURRENT || 
  process.env.STRIPE_SECRET_KEY_PREVIOUS!,
  { apiVersion: '2024-11-20.acacia' }
);
```

---

## Payment Intents

Payment Intents API provides a unified flow for one-time payments with built-in SCA support.

### Creating a Payment Intent

```typescript
// app/api/create-payment-intent/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { stripe } from '@/lib/stripe';

export async function POST(req: NextRequest) {
  try {
    const { amount, currency = 'usd', customerId } = await req.json();

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount * 100, // Convert to cents
      currency,
      customer: customerId,
      automatic_payment_methods: {
        enabled: true,
      },
      metadata: {
        orderId: 'order_123',
        userId: 'user_456',
      },
    });

    return NextResponse.json({
      clientSecret: paymentIntent.client_secret,
    });
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to create payment intent' },
      { status: 500 }
    );
  }
}
```

### Confirming Payment on Client

```typescript
// components/CheckoutForm.tsx
'use client';

import { useState } from 'react';
import {
  PaymentElement,
  useStripe,
  useElements,
} from '@stripe/react-stripe-js';

export function CheckoutForm() {
  const stripe = useStripe();
  const elements = useElements();
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!stripe || !elements) return;

    setLoading(true);

    const { error } = await stripe.confirmPayment({
      elements,
      confirmParams: {
        return_url: `${window.location.origin}/payment-success`,
      },
    });

    if (error) {
      console.error(error.message);
    }

    setLoading(false);
  };

  return (
    <form onSubmit={handleSubmit}>
      <PaymentElement />
      <button disabled={!stripe || loading}>
        {loading ? 'Processing...' : 'Pay'}
      </button>
    </form>
  );
}
```

### Payment Methods

```typescript
// Attach payment method to customer
const paymentMethod = await stripe.paymentMethods.attach(
  'pm_1234',
  { customer: 'cus_1234' }
);

// Set as default payment method
await stripe.customers.update('cus_1234', {
  invoice_settings: {
    default_payment_method: 'pm_1234',
  },
});
```

### 3D Secure / Strong Customer Authentication (SCA)

```typescript
const paymentIntent = await stripe.paymentIntents.create({
  amount: 2000,
  currency: 'eur',
  payment_method_types: ['card'],
  confirmation_method: 'manual',
  confirm: false,
});

// Client confirms with 3DS if required
const { error } = await stripe.confirmCardPayment(
  paymentIntent.client_secret!,
  {
    payment_method: 'pm_1234',
  }
);
```

### Idempotency Keys

Prevent duplicate payments by using idempotency keys.

```typescript
import { randomUUID } from 'crypto';

const idempotencyKey = randomUUID();

const paymentIntent = await stripe.paymentIntents.create(
  {
    amount: 1000,
    currency: 'usd',
  },
  {
    idempotencyKey,
  }
);
```

### ✅ Good: Complete Payment Intent Flow

```typescript
// app/api/payment-intent/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { stripe } from '@/lib/stripe';
import { auth } from '@/lib/auth';

export async function POST(req: NextRequest) {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { amount, description, metadata } = await req.json();

    // Validate amount
    if (!amount || amount < 50) {
      return NextResponse.json(
        { error: 'Amount must be at least $0.50' },
        { status: 400 }
      );
    }

    // Get or create customer
    let customer = await stripe.customers.list({
      email: session.user.email!,
      limit: 1,
    });

    let customerId: string;
    if (customer.data.length > 0) {
      customerId = customer.data[0].id;
    } else {
      const newCustomer = await stripe.customers.create({
        email: session.user.email!,
        metadata: {
          userId: session.user.id,
        },
      });
      customerId = newCustomer.id;
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100),
      currency: 'usd',
      customer: customerId,
      description,
      automatic_payment_methods: {
        enabled: true,
      },
      metadata: {
        userId: session.user.id,
        ...metadata,
      },
    });

    return NextResponse.json({
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    });
  } catch (error) {
    console.error('Payment intent error:', error);
    return NextResponse.json(
      { error: 'Payment intent creation failed' },
      { status: 500 }
    );
  }
}
```

### ❌ Bad: Insecure Payment Intent

```typescript
// NEVER DO THIS - No auth, no validation
export async function POST(req: NextRequest) {
  const { amount } = await req.json();
  
  const paymentIntent = await stripe.paymentIntents.create({
    amount, // No validation, could be negative or huge
    currency: 'usd',
    // No customer, no metadata, no error handling
  });

  return NextResponse.json({ clientSecret: paymentIntent.client_secret });
}
```

### Manual Confirmation Flow

```typescript
// Server: Create payment intent
const paymentIntent = await stripe.paymentIntents.create({
  amount: 2000,
  currency: 'usd',
  confirmation_method: 'manual',
  confirm: false,
  payment_method_types: ['card'],
});

// Client: Confirm payment
const { error, paymentIntent: confirmed } = await stripe.confirmCardPayment(
  clientSecret,
  {
    payment_method: {
      card: cardElement,
      billing_details: { name: 'Customer Name' },
    },
  }
);

// Server: Manually confirm after client validation
const confirmedIntent = await stripe.paymentIntents.confirm(
  paymentIntent.id,
  { payment_method: 'pm_1234' }
);
```

---

## Checkout Sessions

Stripe Checkout provides a pre-built, hosted payment page.

### Creating a Checkout Session

```typescript
// app/api/checkout/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { stripe } from '@/lib/stripe';

export async function POST(req: NextRequest) {
  try {
    const { priceId, quantity = 1 } = await req.json();

    const session = await stripe.checkout.sessions.create({
      mode: 'payment',
      line_items: [
        {
          price: priceId,
          quantity,
        },
      ],
      success_url: `${process.env.NEXT_PUBLIC_URL}/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${process.env.NEXT_PUBLIC_URL}/cancel`,
    });

    return NextResponse.json({ url: session.url });
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to create checkout session' },
      { status: 500 }
    );
  }
}
```

### One-Time Payment Session

```typescript
const session = await stripe.checkout.sessions.create({
  mode: 'payment',
  line_items: [
    {
      price_data: {
        currency: 'usd',
        product_data: {
          name: 'Premium Plan',
          description: 'One-time purchase',
        },
        unit_amount: 9900, // $99.00
      },
      quantity: 1,
    },
  ],
  success_url: `${process.env.NEXT_PUBLIC_URL}/success`,
  cancel_url: `${process.env.NEXT_PUBLIC_URL}/cancel`,
});
```

### Subscription Checkout Session

```typescript
const session = await stripe.checkout.sessions.create({
  mode: 'subscription',
  line_items: [
    {
      price: 'price_1234', // Recurring price ID
      quantity: 1,
    },
  ],
  success_url: `${process.env.NEXT_PUBLIC_URL}/success`,
  cancel_url: `${process.env.NEXT_PUBLIC_URL}/cancel`,
  customer_email: 'customer@example.com',
});
```

### Customer Data Collection

```typescript
const session = await stripe.checkout.sessions.create({
  mode: 'subscription',
  line_items: [{ price: 'price_1234', quantity: 1 }],
  customer_email: 'user@example.com',
  billing_address_collection: 'required',
  shipping_address_collection: {
    allowed_countries: ['US', 'CA', 'GB'],
  },
  phone_number_collection: {
    enabled: true,
  },
  success_url: `${process.env.NEXT_PUBLIC_URL}/success`,
  cancel_url: `${process.env.NEXT_PUBLIC_URL}/cancel`,
});
```

### Redirect to Checkout

```typescript
'use client';

import { loadStripe } from '@stripe/stripe-js';

const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!);

export function CheckoutButton({ priceId }: { priceId: string }) {
  const handleCheckout = async () => {
    const response = await fetch('/api/checkout', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ priceId }),
    });

    const { url } = await response.json();
    window.location.href = url;
  };

  return <button onClick={handleCheckout}>Checkout</button>;
}
```

### ✅ Good: Complete Checkout Flow

```typescript
// app/api/checkout/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { stripe } from '@/lib/stripe';
import { auth } from '@/lib/auth';

export async function POST(req: NextRequest) {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { items, mode = 'payment' } = await req.json();

    // Validate items
    if (!items || items.length === 0) {
      return NextResponse.json(
        { error: 'No items provided' },
        { status: 400 }
      );
    }

    const checkoutSession = await stripe.checkout.sessions.create({
      mode,
      customer_email: session.user.email!,
      line_items: items.map((item: any) => ({
        price: item.priceId,
        quantity: item.quantity || 1,
      })),
      success_url: `${process.env.NEXT_PUBLIC_URL}/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${process.env.NEXT_PUBLIC_URL}/cancel`,
      metadata: {
        userId: session.user.id,
      },
      allow_promotion_codes: true,
      billing_address_collection: 'auto',
    });

    return NextResponse.json({ 
      url: checkoutSession.url,
      sessionId: checkoutSession.id,
    });
  } catch (error) {
    console.error('Checkout error:', error);
    return NextResponse.json(
      { error: 'Checkout creation failed' },
      { status: 500 }
    );
  }
}
```

### ❌ Bad: Insecure Checkout

```typescript
// NEVER DO THIS - No auth, accepts any data from client
export async function POST(req: NextRequest) {
  const { amount, name } = await req.json();
  
  const session = await stripe.checkout.sessions.create({
    mode: 'payment',
    line_items: [{
      price_data: {
        currency: 'usd',
        product_data: { name }, // Unvalidated user input
        unit_amount: amount, // User controls price!
      },
      quantity: 1,
    }],
    success_url: 'http://localhost:3000/success', // Hardcoded URL
    cancel_url: 'http://localhost:3000/cancel',
  });

  return NextResponse.json({ url: session.url });
}
```

---

## Subscriptions

Stripe subscriptions enable recurring billing with flexible plans and pricing.

### Creating a Subscription

```typescript
const subscription = await stripe.subscriptions.create({
  customer: 'cus_1234',
  items: [
    {
      price: 'price_1234', // Monthly or annual price ID
    },
  ],
  payment_behavior: 'default_incomplete',
  payment_settings: {
    save_default_payment_method: 'on_subscription',
  },
  expand: ['latest_invoice.payment_intent'],
});
```

### Plans and Prices

```typescript
// Create a product
const product = await stripe.products.create({
  name: 'Premium Plan',
  description: 'Access to all premium features',
});

// Create monthly price
const monthlyPrice = await stripe.prices.create({
  product: product.id,
  unit_amount: 1999, // $19.99
  currency: 'usd',
  recurring: {
    interval: 'month',
  },
});

// Create annual price
const annualPrice = await stripe.prices.create({
  product: product.id,
  unit_amount: 19900, // $199.00
  currency: 'usd',
  recurring: {
    interval: 'year',
  },
});
```

### Metered Billing

```typescript
// Create metered price
const meteredPrice = await stripe.prices.create({
  product: 'prod_1234',
  currency: 'usd',
  recurring: {
    interval: 'month',
    usage_type: 'metered',
  },
  billing_scheme: 'tiered',
  tiers_mode: 'graduated',
  tiers: [
    {
      up_to: 100,
      unit_amount: 500, // $5 per unit
    },
    {
      up_to: 1000,
      unit_amount: 400, // $4 per unit
    },
    {
      up_to: 'inf',
      unit_amount: 300, // $3 per unit
    },
  ],
});

// Record usage
const usageRecord = await stripe.subscriptionItems.createUsageRecord(
  'si_1234',
  {
    quantity: 150,
    timestamp: Math.floor(Date.now() / 1000),
    action: 'increment',
  }
);
```

### Trial Periods

```typescript
const subscription = await stripe.subscriptions.create({
  customer: 'cus_1234',
  items: [{ price: 'price_1234' }],
  trial_period_days: 14,
  trial_settings: {
    end_behavior: {
      missing_payment_method: 'cancel',
    },
  },
});
```

### Updating Subscriptions

```typescript
// Upgrade subscription
const updated = await stripe.subscriptions.update('sub_1234', {
  items: [
    {
      id: 'si_1234',
      price: 'price_premium', // New price
    },
  ],
  proration_behavior: 'create_prorations',
});

// Add new item to subscription
const addItem = await stripe.subscriptions.update('sub_1234', {
  items: [
    {
      price: 'price_addon',
      quantity: 1,
    },
  ],
});
```

### Canceling Subscriptions

```typescript
// Cancel at period end
const canceled = await stripe.subscriptions.update('sub_1234', {
  cancel_at_period_end: true,
});

// Cancel immediately
const canceledNow = await stripe.subscriptions.cancel('sub_1234');

// Cancel with refund
const canceledWithRefund = await stripe.subscriptions.cancel('sub_1234', {
  prorate: true,
});
```

### Proration

```typescript
// Enable proration for upgrades
const subscription = await stripe.subscriptions.update('sub_1234', {
  items: [
    {
      id: 'si_1234',
      price: 'price_pro',
    },
  ],
  proration_behavior: 'create_prorations',
  proration_date: Math.floor(Date.now() / 1000),
});

// Disable proration
const noProrateUpdate = await stripe.subscriptions.update('sub_1234', {
  items: [{ id: 'si_1234', price: 'price_new' }],
  proration_behavior: 'none',
});
```

### ✅ Good: Complete Subscription Management

```typescript
// app/api/subscriptions/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { stripe } from '@/lib/stripe';
import { auth } from '@/lib/auth';
import { db } from '@/lib/db';

export async function POST(req: NextRequest) {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { priceId } = await req.json();

    // Get or create Stripe customer
    const user = await db.user.findUnique({
      where: { id: session.user.id },
      select: { stripeCustomerId: true, email: true },
    });

    let customerId = user?.stripeCustomerId;

    if (!customerId) {
      const customer = await stripe.customers.create({
        email: session.user.email!,
        metadata: {
          userId: session.user.id,
        },
      });
      customerId = customer.id;

      // Save customer ID
      await db.user.update({
        where: { id: session.user.id },
        data: { stripeCustomerId: customerId },
      });
    }

    // Create subscription
    const subscription = await stripe.subscriptions.create({
      customer: customerId,
      items: [{ price: priceId }],
      payment_behavior: 'default_incomplete',
      payment_settings: {
        save_default_payment_method: 'on_subscription',
      },
      expand: ['latest_invoice.payment_intent'],
      metadata: {
        userId: session.user.id,
      },
    });

    const invoice = subscription.latest_invoice as Stripe.Invoice;
    const paymentIntent = invoice.payment_intent as Stripe.PaymentIntent;

    return NextResponse.json({
      subscriptionId: subscription.id,
      clientSecret: paymentIntent.client_secret,
    });
  } catch (error) {
    console.error('Subscription error:', error);
    return NextResponse.json(
      { error: 'Subscription creation failed' },
      { status: 500 }
    );
  }
}

export async function DELETE(req: NextRequest) {
  try {
    const session = await auth();
    if (!session?.user?.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { searchParams } = new URL(req.url);
    const subscriptionId = searchParams.get('id');

    if (!subscriptionId) {
      return NextResponse.json(
        { error: 'Subscription ID required' },
        { status: 400 }
      );
    }

    // Verify ownership
    const subscription = await stripe.subscriptions.retrieve(subscriptionId);
    const customer = await stripe.customers.retrieve(subscription.customer as string);
    
    if (customer.metadata.userId !== session.user.id) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
    }

    // Cancel at period end
    const canceled = await stripe.subscriptions.update(subscriptionId, {
      cancel_at_period_end: true,
    });

    return NextResponse.json({
      status: canceled.status,
      cancelAt: canceled.cancel_at,
    });
  } catch (error) {
    console.error('Cancel error:', error);
    return NextResponse.json(
      { error: 'Cancellation failed' },
      { status: 500 }
    );
  }
}
```

### ❌ Bad: Insecure Subscription

```typescript
// NEVER DO THIS
export async function POST(req: NextRequest) {
  const { customerId, priceId } = await req.json();
  
  // No auth check, user can subscribe anyone!
  const subscription = await stripe.subscriptions.create({
    customer: customerId,
    items: [{ price: priceId }],
  });

  return NextResponse.json({ id: subscription.id });
}
```

---

## Webhooks

Webhooks notify your application about events in Stripe.

### Webhook Endpoint Setup

```typescript
// app/api/webhooks/stripe/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { stripe } from '@/lib/stripe';
import Stripe from 'stripe';

export async function POST(req: NextRequest) {
  const body = await req.text();
  const signature = req.headers.get('stripe-signature');

  if (!signature) {
    return NextResponse.json(
      { error: 'No signature' },
      { status: 400 }
    );
  }

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    );
  } catch (error) {
    console.error('Webhook signature verification failed:', error);
    return NextResponse.json(
      { error: 'Invalid signature' },
      { status: 400 }
    );
  }

  // Handle event
  try {
    await handleWebhookEvent(event);
    return NextResponse.json({ received: true });
  } catch (error) {
    console.error('Webhook handler failed:', error);
    return NextResponse.json(
      { error: 'Handler failed' },
      { status: 500 }
    );
  }
}
```

### Signature Verification (CRITICAL)

```typescript
import { headers } from 'next/headers';
import Stripe from 'stripe';
import { stripe } from '@/lib/stripe';

export async function POST(req: Request) {
  const body = await req.text();
  const headersList = await headers();
  const signature = headersList.get('stripe-signature')!;

  let event: Stripe.Event;

  try {
    // ALWAYS verify signature
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    );
  } catch (err: any) {
    console.error(`Webhook signature verification failed:`, err.message);
    return new Response(`Webhook Error: ${err.message}`, { status: 400 });
  }

  // Process verified event
  console.log('✅ Verified event:', event.type);
  
  return new Response(JSON.stringify({ received: true }), { status: 200 });
}
```

### Event Types and Handlers

```typescript
async function handleWebhookEvent(event: Stripe.Event) {
  switch (event.type) {
    case 'payment_intent.succeeded':
      await handlePaymentIntentSucceeded(event.data.object as Stripe.PaymentIntent);
      break;
    
    case 'payment_intent.payment_failed':
      await handlePaymentIntentFailed(event.data.object as Stripe.PaymentIntent);
      break;
    
    case 'customer.subscription.created':
      await handleSubscriptionCreated(event.data.object as Stripe.Subscription);
      break;
    
    case 'customer.subscription.updated':
      await handleSubscriptionUpdated(event.data.object as Stripe.Subscription);
      break;
    
    case 'customer.subscription.deleted':
      await handleSubscriptionDeleted(event.data.object as Stripe.Subscription);
      break;
    
    case 'invoice.payment_succeeded':
      await handleInvoicePaymentSucceeded(event.data.object as Stripe.Invoice);
      break;
    
    case 'invoice.payment_failed':
      await handleInvoicePaymentFailed(event.data.object as Stripe.Invoice);
      break;
    
    case 'checkout.session.completed':
      await handleCheckoutSessionCompleted(event.data.object as Stripe.Checkout.Session);
      break;
    
    default:
      console.log(`Unhandled event type: ${event.type}`);
  }
}
```

### Idempotent Event Processing

```typescript
import { db } from '@/lib/db';

async function handlePaymentIntentSucceeded(paymentIntent: Stripe.PaymentIntent) {
  // Check if already processed
  const existing = await db.processedEvent.findUnique({
    where: { eventId: paymentIntent.id },
  });

  if (existing) {
    console.log('Event already processed:', paymentIntent.id);
    return;
  }

  // Process payment
  await db.$transaction(async (tx) => {
    // Update order status
    await tx.order.update({
      where: { paymentIntentId: paymentIntent.id },
      data: { status: 'paid' },
    });

    // Mark event as processed
    await tx.processedEvent.create({
      data: {
        eventId: paymentIntent.id,
        type: 'payment_intent.succeeded',
        processedAt: new Date(),
      },
    });
  });

  console.log('✅ Payment succeeded:', paymentIntent.id);
}
```

### Testing Webhooks (Stripe CLI)

```bash
# Install Stripe CLI
brew install stripe/stripe-cli/stripe

# Login
stripe login

# Forward webhooks to local server
stripe listen --forward-to localhost:3000/api/webhooks/stripe

# Trigger test events
stripe trigger payment_intent.succeeded
stripe trigger customer.subscription.created
stripe trigger invoice.payment_failed
```

### ✅ Good: Complete Webhook Handler

```typescript
// app/api/webhooks/stripe/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { stripe } from '@/lib/stripe';
import { db } from '@/lib/db';
import Stripe from 'stripe';

export async function POST(req: NextRequest) {
  const body = await req.text();
  const signature = req.headers.get('stripe-signature');

  if (!signature) {
    console.error('Missing stripe-signature header');
    return NextResponse.json(
      { error: 'Missing signature' },
      { status: 400 }
    );
  }

  let event: Stripe.Event;

  try {
    // CRITICAL: Always verify signature
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    );
  } catch (error: any) {
    console.error('Webhook signature verification failed:', error.message);
    return NextResponse.json(
      { error: 'Invalid signature' },
      { status: 400 }
    );
  }

  console.log('✅ Webhook verified:', event.type, event.id);

  try {
    // Idempotency check
    const existing = await db.stripeEvent.findUnique({
      where: { id: event.id },
    });

    if (existing) {
      console.log('Event already processed:', event.id);
      return NextResponse.json({ received: true });
    }

    // Process event
    await processStripeEvent(event);

    // Mark as processed
    await db.stripeEvent.create({
      data: {
        id: event.id,
        type: event.type,
        processedAt: new Date(),
      },
    });

    return NextResponse.json({ received: true });
  } catch (error: any) {
    console.error('Webhook processing error:', error);
    // Return 200 to prevent retries for unrecoverable errors
    return NextResponse.json(
      { error: error.message },
      { status: 200 }
    );
  }
}

async function processStripeEvent(event: Stripe.Event) {
  switch (event.type) {
    case 'checkout.session.completed': {
      const session = event.data.object as Stripe.Checkout.Session;
      
      await db.user.update({
        where: { email: session.customer_email! },
        data: {
          stripeCustomerId: session.customer as string,
          subscriptionStatus: 'active',
        },
      });
      break;
    }

    case 'customer.subscription.updated': {
      const subscription = event.data.object as Stripe.Subscription;
      
      await db.user.update({
        where: { stripeCustomerId: subscription.customer as string },
        data: {
          subscriptionStatus: subscription.status,
          subscriptionId: subscription.id,
          currentPeriodEnd: new Date(subscription.current_period_end * 1000),
        },
      });
      break;
    }

    case 'customer.subscription.deleted': {
      const subscription = event.data.object as Stripe.Subscription;
      
      await db.user.update({
        where: { stripeCustomerId: subscription.customer as string },
        data: {
          subscriptionStatus: 'canceled',
          subscriptionId: null,
        },
      });
      break;
    }

    default:
      console.log(`Unhandled event: ${event.type}`);
  }
}

export const runtime = 'nodejs';
```

### ❌ Bad: No Signature Verification

```typescript
// NEVER DO THIS - Massive security vulnerability!
export async function POST(req: NextRequest) {
  const body = await req.json();
  
  // No signature verification - anyone can send fake events!
  const event = body;
  
  if (event.type === 'payment_intent.succeeded') {
    // Attacker could fake successful payments
    await grantPremiumAccess(event.data.object.customer);
  }

  return NextResponse.json({ received: true });
}
```

### Webhook Retry Logic

Stripe retries failed webhooks automatically. Return appropriate status codes:

```typescript
export async function POST(req: NextRequest) {
  try {
    const event = await verifyWebhook(req);
    
    await handleEvent(event);
    
    return NextResponse.json({ received: true }); // 200 OK
  } catch (error: any) {
    if (error.retryable) {
      // Return 500 to trigger Stripe retry
      return NextResponse.json(
        { error: error.message },
        { status: 500 }
      );
    } else {
      // Return 200 to prevent retries
      console.error('Non-retryable error:', error);
      return NextResponse.json({ received: true });
    }
  }
}
```

---

## Customer Management

### Creating Customers

```typescript
const customer = await stripe.customers.create({
  email: 'customer@example.com',
  name: 'John Doe',
  metadata: {
    userId: 'user_123',
  },
  payment_method: 'pm_1234',
  invoice_settings: {
    default_payment_method: 'pm_1234',
  },
});
```

### Updating Customer Data

```typescript
const updated = await stripe.customers.update('cus_1234', {
  name: 'Jane Doe',
  email: 'jane@example.com',
  metadata: {
    plan: 'premium',
    renewalDate: '2024-12-31',
  },
});
```

### Customer Metadata

```typescript
// Store custom data
await stripe.customers.update('cus_1234', {
  metadata: {
    userId: 'user_456',
    accountType: 'business',
    signupDate: '2024-01-01',
    referralCode: 'REF123',
  },
});

// Retrieve customer with metadata
const customer = await stripe.customers.retrieve('cus_1234');
console.log(customer.metadata.userId);
```

### Managing Payment Methods

```typescript
// List payment methods
const paymentMethods = await stripe.paymentMethods.list({
  customer: 'cus_1234',
  type: 'card',
});

// Attach payment method
await stripe.paymentMethods.attach('pm_1234', {
  customer: 'cus_1234',
});

// Detach payment method
await stripe.paymentMethods.detach('pm_1234');

// Set default payment method
await stripe.customers.update('cus_1234', {
  invoice_settings: {
    default_payment_method: 'pm_1234',
  },
});
```

### Customer Portal

```typescript
// app/api/portal/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { stripe } from '@/lib/stripe';
import { auth } from '@/lib/auth';

export async function POST(req: NextRequest) {
  try {
    const session = await auth();
    if (!session?.user?.stripeCustomerId) {
      return NextResponse.json({ error: 'No customer found' }, { status: 404 });
    }

    const portalSession = await stripe.billingPortal.sessions.create({
      customer: session.user.stripeCustomerId,
      return_url: `${process.env.NEXT_PUBLIC_URL}/account`,
    });

    return NextResponse.json({ url: portalSession.url });
  } catch (error) {
    return NextResponse.json(
      { error: 'Portal creation failed' },
      { status: 500 }
    );
  }
}
```

### ✅ Good: Customer Management

```typescript
// lib/stripe-customer.ts
import { stripe } from '@/lib/stripe';
import { db } from '@/lib/db';

export async function getOrCreateCustomer(userId: string) {
  const user = await db.user.findUnique({
    where: { id: userId },
    select: { stripeCustomerId: true, email: true, name: true },
  });

  if (!user) {
    throw new Error('User not found');
  }

  // Return existing customer
  if (user.stripeCustomerId) {
    return user.stripeCustomerId;
  }

  // Create new customer
  const customer = await stripe.customers.create({
    email: user.email,
    name: user.name || undefined,
    metadata: {
      userId,
    },
  });

  // Save customer ID
  await db.user.update({
    where: { id: userId },
    data: { stripeCustomerId: customer.id },
  });

  return customer.id;
}
```

### ❌ Bad: Duplicate Customers

```typescript
// NEVER DO THIS - Creates duplicate customers
export async function createCustomer(email: string) {
  // No check for existing customer!
  const customer = await stripe.customers.create({
    email, // Could create multiple customers with same email
  });
  
  return customer.id;
}
```

---

## Error Handling

### Stripe Error Types

```typescript
import Stripe from 'stripe';

try {
  await stripe.paymentIntents.create({
    amount: 1000,
    currency: 'usd',
  });
} catch (error) {
  if (error instanceof Stripe.errors.StripeCardError) {
    // Card was declined
    console.error('Card error:', error.message);
    console.error('Code:', error.code);
    console.error('Decline code:', error.decline_code);
  } else if (error instanceof Stripe.errors.StripeRateLimitError) {
    // Too many requests
    console.error('Rate limit exceeded');
  } else if (error instanceof Stripe.errors.StripeInvalidRequestError) {
    // Invalid parameters
    console.error('Invalid request:', error.message);
  } else if (error instanceof Stripe.errors.StripeAPIError) {
    // Stripe API error
    console.error('API error:', error.message);
  } else if (error instanceof Stripe.errors.StripeConnectionError) {
    // Network error
    console.error('Connection error');
  } else if (error instanceof Stripe.errors.StripeAuthenticationError) {
    // Authentication error
    console.error('Authentication failed');
  } else {
    console.error('Unknown error:', error);
  }
}
```

### Retrying Failed Payments

```typescript
async function retryPayment(paymentIntentId: string) {
  try {
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    if (paymentIntent.status === 'requires_payment_method') {
      // Retry with new payment method
      const updated = await stripe.paymentIntents.update(paymentIntentId, {
        payment_method: 'pm_new',
      });

      return await stripe.paymentIntents.confirm(updated.id);
    }

    return paymentIntent;
  } catch (error) {
    console.error('Retry failed:', error);
    throw error;
  }
}
```

### Handling Declined Cards

```typescript
import Stripe from 'stripe';

async function handlePaymentError(error: any): Promise<string> {
  if (error instanceof Stripe.errors.StripeCardError) {
    switch (error.code) {
      case 'card_declined':
        return 'Your card was declined. Please try a different payment method.';
      
      case 'insufficient_funds':
        return 'Insufficient funds. Please use a different card.';
      
      case 'expired_card':
        return 'Your card has expired. Please use a different card.';
      
      case 'incorrect_cvc':
        return 'Incorrect security code. Please check and try again.';
      
      case 'processing_error':
        return 'An error occurred. Please try again.';
      
      default:
        return 'Payment failed. Please try a different payment method.';
    }
  }

  return 'An unexpected error occurred. Please try again.';
}
```

### User-Friendly Error Messages

```typescript
// app/api/payment/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { stripe } from '@/lib/stripe';
import Stripe from 'stripe';

export async function POST(req: NextRequest) {
  try {
    const { amount, paymentMethodId } = await req.json();

    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency: 'usd',
      payment_method: paymentMethodId,
      confirm: true,
    });

    return NextResponse.json({ success: true });
  } catch (error) {
    if (error instanceof Stripe.errors.StripeCardError) {
      return NextResponse.json(
        {
          error: 'payment_failed',
          message: getUserFriendlyMessage(error.code),
          code: error.code,
        },
        { status: 400 }
      );
    }

    return NextResponse.json(
      {
        error: 'internal_error',
        message: 'An unexpected error occurred. Please try again.',
      },
      { status: 500 }
    );
  }
}

function getUserFriendlyMessage(code?: string): string {
  const messages: Record<string, string> = {
    card_declined: 'Your card was declined. Please try another card.',
    insufficient_funds: 'Insufficient funds. Please try another card.',
    expired_card: 'Your card has expired.',
    incorrect_cvc: 'The security code is incorrect.',
    processing_error: 'A processing error occurred. Please try again.',
  };

  return messages[code || ''] || 'Payment failed. Please try again.';
}
```

### ✅ Good: Comprehensive Error Handling

```typescript
import Stripe from 'stripe';
import { stripe } from '@/lib/stripe';

export async function processPayment(
  amount: number,
  paymentMethodId: string
): Promise<{ success: boolean; error?: string }> {
  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100),
      currency: 'usd',
      payment_method: paymentMethodId,
      confirm: true,
      error_on_requires_action: true,
    });

    return { success: true };
  } catch (error) {
    console.error('Payment processing error:', error);

    if (error instanceof Stripe.errors.StripeCardError) {
      return {
        success: false,
        error: getUserFriendlyErrorMessage(error),
      };
    }

    if (error instanceof Stripe.errors.StripeInvalidRequestError) {
      console.error('Invalid request:', error.message);
      return {
        success: false,
        error: 'Invalid payment details. Please check and try again.',
      };
    }

    if (error instanceof Stripe.errors.StripeRateLimitError) {
      console.error('Rate limit exceeded');
      return {
        success: false,
        error: 'Too many requests. Please try again in a moment.',
      };
    }

    return {
      success: false,
      error: 'An unexpected error occurred. Please try again.',
    };
  }
}

function getUserFriendlyErrorMessage(error: Stripe.errors.StripeCardError): string {
  const code = error.code;
  const declineCode = error.decline_code;

  if (declineCode === 'generic_decline') {
    return 'Your card was declined. Please contact your bank.';
  }

  const messages: Record<string, string> = {
    card_declined: 'Your card was declined. Please try another card.',
    insufficient_funds: 'Insufficient funds on your card.',
    lost_card: 'This card has been reported lost.',
    stolen_card: 'This card has been reported stolen.',
    expired_card: 'Your card has expired.',
    incorrect_cvc: 'The security code is incorrect.',
    incorrect_number: 'The card number is incorrect.',
    invalid_expiry_month: 'The expiration month is invalid.',
    invalid_expiry_year: 'The expiration year is invalid.',
    processing_error: 'A processing error occurred. Please try again.',
  };

  return messages[code] || 'Payment failed. Please try another payment method.';
}
```

### ❌ Bad: Generic Error Handling

```typescript
// NEVER DO THIS - Exposes internal errors, no retry logic
export async function POST(req: NextRequest) {
  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: 1000,
      currency: 'usd',
    });
    
    return NextResponse.json({ success: true });
  } catch (error: any) {
    // Exposes raw Stripe error to user
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
```

---

## Security Best Practices

1. **Always verify webhook signatures**
2. **Use environment variables for API keys**
3. **Validate all input on the server**
4. **Never trust client-side data for prices**
5. **Implement idempotency for webhooks**
6. **Use HTTPS in production**
7. **Rotate API keys periodically**
8. **Monitor webhook failures**
9. **Implement rate limiting**
10. **Log security events**

## Performance Optimization

1. **Cache customer lookups**
2. **Use webhooks for async processing**
3. **Batch subscription updates**
4. **Implement retry logic with exponential backoff**
5. **Use Stripe's pagination for large datasets**

## Testing

```bash
# Use test mode keys
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...

# Test cards
4242 4242 4242 4242  # Success
4000 0000 0000 9995  # Declined
4000 0025 0000 3155  # 3D Secure required

# Stripe CLI for webhooks
stripe listen --forward-to localhost:3000/api/webhooks/stripe
stripe trigger payment_intent.succeeded
```

---

*Last updated: 2024-11-20*
*Stripe API Version: 2024-11-20.acacia*
*Total Lines: 900+*
