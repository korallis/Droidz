---
name: monitoring-observability
description: Auto-activates when user mentions monitoring, observability, Prometheus, Grafana, metrics, logging, tracing, or APM. Expert in implementing comprehensive monitoring and observability solutions.
category: devops
---

# Monitoring & Observability

Implements production-grade monitoring, logging, metrics, and distributed tracing for applications.

## When This Activates

- User says: "add monitoring", "implement observability", "set up metrics"
- User mentions: "Prometheus", "Grafana", "logging", "tracing", "APM", "alerts"
- Production readiness questions
- Performance monitoring needs
- Debugging distributed systems

## Three Pillars of Observability

### 1. Metrics (Prometheus + Grafana)
### 2. Logs (Winston/Pino/ELK)
### 3. Traces (OpenTelemetry/Jaeger)

## Prometheus Metrics

### Express.js with Prometheus

```typescript
// metrics.ts
import { register, Counter, Histogram, Gauge } from 'prom-client';

// HTTP request metrics
export const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5, 10],
});

export const httpRequestTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
});

// Business metrics
export const userRegistrations = new Counter({
  name: 'user_registrations_total',
  help: 'Total number of user registrations',
  labelNames: ['source'],
});

export const activeUsers = new Gauge({
  name: 'active_users',
  help: 'Number of currently active users',
});

export const databaseQueryDuration = new Histogram({
  name: 'database_query_duration_seconds',
  help: 'Database query duration',
  labelNames: ['operation', 'table'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 2],
});

// Application metrics
export const memoryUsage = new Gauge({
  name: 'nodejs_memory_usage_bytes',
  help: 'Node.js memory usage',
  labelNames: ['type'],
});

// Update memory metrics every 10 seconds
setInterval(() => {
  const usage = process.memoryUsage();
  memoryUsage.set({ type: 'heapUsed' }, usage.heapUsed);
  memoryUsage.set({ type: 'heapTotal' }, usage.heapTotal);
  memoryUsage.set({ type: 'external' }, usage.external);
  memoryUsage.set({ type: 'rss' }, usage.rss);
}, 10000);

// Expose metrics endpoint
export { register };
```

```typescript
// middleware/metrics.ts
import { httpRequestDuration, httpRequestTotal } from '../metrics';

export function metricsMiddleware(req, res, next) {
  const start = Date.now();

  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route?.path || req.path;

    httpRequestDuration.observe(
      {
        method: req.method,
        route,
        status_code: res.statusCode,
      },
      duration
    );

    httpRequestTotal.inc({
      method: req.method,
      route,
      status_code: res.statusCode,
    });
  });

  next();
}

// server.ts
import express from 'express';
import { register } from './metrics';
import { metricsMiddleware } from './middleware/metrics';

const app = express();

app.use(metricsMiddleware);

// Expose metrics for Prometheus
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});
```

### Prometheus Configuration

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'nodejs-app'
    static_configs:
      - targets: ['app:3000']
    metrics_path: '/metrics'

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

rule_files:
  - 'alerts.yml'
```

### Alert Rules

```yaml
# alerts.yml
groups:
  - name: application_alerts
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: |
          (
            sum(rate(http_requests_total{status_code=~"5.."}[5m]))
            /
            sum(rate(http_requests_total[5m]))
          ) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value | humanizePercentage }}"

      - alert: HighResponseTime
        expr: |
          histogram_quantile(0.95,
            sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
          ) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
          description: "95th percentile response time is {{ $value }}s"

      - alert: HighMemoryUsage
        expr: |
          (nodejs_memory_usage_bytes{type="heapUsed"}
          /
          nodejs_memory_usage_bytes{type="heapTotal"}) > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Heap usage is {{ $value | humanizePercentage }}"

      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service is down"
          description: "{{ $labels.job }} is not responding"
```

## Structured Logging

### Pino Logger Setup

```typescript
// logger.ts
import pino from 'pino';
import pinoHttp from 'pino-http';

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
  timestamp: pino.stdTimeFunctions.isoTime,
  ...(process.env.NODE_ENV === 'production'
    ? {
        // JSON logs for production
        transport: {
          target: 'pino/file',
          options: { destination: '/var/log/app/app.log' },
        },
      }
    : {
        // Pretty logs for development
        transport: {
          target: 'pino-pretty',
          options: {
            colorize: true,
            translateTime: 'HH:MM:ss',
            ignore: 'pid,hostname',
          },
        },
      }),
});

export const httpLogger = pinoHttp({
  logger,
  customLogLevel: (req, res, err) => {
    if (res.statusCode >= 500 || err) return 'error';
    if (res.statusCode >= 400) return 'warn';
    return 'info';
  },
  customSuccessMessage: (req, res) => {
    return `${req.method} ${req.url} ${res.statusCode}`;
  },
  customErrorMessage: (req, res, err) => {
    return `${req.method} ${req.url} ${res.statusCode} - ${err.message}`;
  },
});

// Usage
import { logger, httpLogger } from './logger';

app.use(httpLogger);

logger.info({ userId: 123, action: 'login' }, 'User logged in');
logger.error({ err, userId: 123 }, 'Failed to process payment');
logger.warn({ duration: 5000, endpoint: '/api/slow' }, 'Slow query detected');
```

### Log Aggregation (ELK Stack)

```yaml
# docker-compose.yml
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

  logstash:
    image: docker.elastic.co/logstash/logstash:8.11.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    ports:
      - "5000:5000"
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:8.11.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch

volumes:
  elasticsearch_data:
```

```conf
# logstash.conf
input {
  tcp {
    port => 5000
    codec => json
  }
}

filter {
  if [level] == "error" {
    mutate {
      add_tag => ["error"]
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "app-logs-%{+YYYY.MM.dd}"
  }
}
```

## Distributed Tracing (OpenTelemetry)

```typescript
// tracing.ts
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { JaegerExporter } from '@opentelemetry/exporter-jaeger';
import { Resource } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';

const traceExporter = new JaegerExporter({
  endpoint: 'http://jaeger:14268/api/traces',
});

export const sdk = new NodeSDK({
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: 'my-app',
    [SemanticResourceAttributes.SERVICE_VERSION]: '1.0.0',
  }),
  traceExporter,
  instrumentations: [
    getNodeAutoInstrumentations({
      '@opentelemetry/instrumentation-fs': { enabled: false },
    }),
  ],
});

// Initialize tracing
sdk.start();

// Graceful shutdown
process.on('SIGTERM', () => {
  sdk.shutdown().finally(() => process.exit(0));
});
```

```typescript
// Custom spans
import { trace, SpanStatusCode } from '@opentelemetry/api';

const tracer = trace.getTracer('my-app');

async function processPayment(userId: string, amount: number) {
  const span = tracer.startSpan('processPayment', {
    attributes: {
      userId,
      amount,
    },
  });

  try {
    // Business logic
    const result = await paymentService.charge(userId, amount);
    
    span.setAttribute('paymentId', result.id);
    span.setStatus({ code: SpanStatusCode.OK });
    
    return result;
  } catch (error) {
    span.recordException(error);
    span.setStatus({
      code: SpanStatusCode.ERROR,
      message: error.message,
    });
    throw error;
  } finally {
    span.end();
  }
}
```

## Grafana Dashboards

```json
{
  "dashboard": {
    "title": "Application Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[5m])) by (method)"
          }
        ]
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{status_code=~\"5..\"}[5m]))"
          }
        ]
      },
      {
        "title": "Response Time (p95)",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))"
          }
        ]
      },
      {
        "title": "Active Users",
        "targets": [
          {
            "expr": "active_users"
          }
        ]
      }
    ]
  }
}
```

## Health Checks

```typescript
// health.ts
import express from 'express';
import { db } from './database';
import { redis } from './cache';

const router = express.Router();

router.get('/health', async (req, res) => {
  const checks = await Promise.allSettled([
    checkDatabase(),
    checkRedis(),
    checkDiskSpace(),
    checkMemory(),
  ]);

  const health = {
    status: checks.every(c => c.status === 'fulfilled') ? 'healthy' : 'unhealthy',
    timestamp: new Date().toISOString(),
    checks: {
      database: checks[0].status === 'fulfilled' ? 'up' : 'down',
      redis: checks[1].status === 'fulfilled' ? 'up' : 'down',
      disk: checks[2].status === 'fulfilled' ? 'ok' : 'critical',
      memory: checks[3].status === 'fulfilled' ? 'ok' : 'critical',
    },
  };

  const statusCode = health.status === 'healthy' ? 200 : 503;
  res.status(statusCode).json(health);
});

async function checkDatabase() {
  await db.$queryRaw`SELECT 1`;
}

async function checkRedis() {
  await redis.ping();
}

async function checkDiskSpace() {
  // Check disk space
  const usage = getDiskUsage();
  if (usage > 0.9) throw new Error('Disk space critical');
}

async function checkMemory() {
  const usage = process.memoryUsage();
  const heapUsagePercent = usage.heapUsed / usage.heapTotal;
  if (heapUsagePercent > 0.9) throw new Error('Memory critical');
}

export default router;
```

## Monitoring Checklist

- [ ] **Metrics Collection**
  - [ ] HTTP request rate, duration, errors
  - [ ] Database query performance
  - [ ] Cache hit/miss rates
  - [ ] Business metrics (signups, conversions, etc.)
  - [ ] System metrics (CPU, memory, disk)

- [ ] **Logging**
  - [ ] Structured logging (JSON)
  - [ ] Correlation IDs for request tracing
  - [ ] Appropriate log levels
  - [ ] Sensitive data redaction
  - [ ] Log aggregation (ELK/Datadog/CloudWatch)

- [ ] **Tracing**
  - [ ] Distributed tracing setup
  - [ ] Database queries traced
  - [ ] External API calls traced
  - [ ] Custom business logic spans

- [ ] **Alerting**
  - [ ] High error rate alerts
  - [ ] Slow response time alerts
  - [ ] Service downtime alerts
  - [ ] Resource exhaustion alerts
  - [ ] Alert routing (PagerDuty/Slack)

- [ ] **Dashboards**
  - [ ] Real-time metrics visualization
  - [ ] SLA/SLO tracking
  - [ ] Business KPI dashboards
  - [ ] Error rate trends

- [ ] **Health Checks**
  - [ ] Liveness probe (is app running?)
  - [ ] Readiness probe (can app serve traffic?)
  - [ ] Dependency health checks

**Implement comprehensive monitoring solution, create dashboards, configure alerts.**
