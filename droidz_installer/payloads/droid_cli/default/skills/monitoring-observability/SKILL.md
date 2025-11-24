# Monitoring & Observability - System Health

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
