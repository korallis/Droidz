---
name: monitoring-observability
description: Setting up metrics, alerts, dashboards.. Use when monitoring observability. Use when setting up logging, metrics, alerts, or observability for applications.
---

# Monitoring & Observability - System Health

## When to use this skill

- Setting up metrics, alerts, dashboards.
- When working on related tasks or features
- During development that requires this expertise

**Use when**: Setting up metrics, alerts, dashboards.

## Three Pillars
1. **Metrics** - Time-series data (CPU, memory, requests/sec)
2. **Logs** - Event records with context
3. **Traces** - Request flow through system

## Example
\`\`\`typescript
import * as Sentry from '@sentry/node';
import { metrics } from './metrics';

app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    metrics.histogram('request_duration', Date.now() - start, {
      method: req.method,
      route: req.route?.path,
      status: res.statusCode
    });
  });
  next();
});
\`\`\`

## Resources
- [Observability Guide](https://www.honeycomb.io/what-is-observability)
- [Grafana](https://grafana.com/)
- [Sentry](https://sentry.io/)
