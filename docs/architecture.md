# Architecture

## Deployment path

```text
Developer
   |
   v
GitHub pull request
   |
   v
GitHub Actions CI
   |
   v
Git desired state in main
   |
   v
Argo CD Application
   |
   v
Kubernetes API
   |
   v
Namespace, Deployment, Service, ResourceQuota, LimitRange
```

The application desired state lives at `services/payments-api`. Argo CD watches that path and reconciles the Kubernetes objects into the `payments` namespace.

The tenant baseline is managed separately by the `payments-tenant-baseline` Argo CD Application. It supplies namespace labels, ResourceQuota, and LimitRange.

## Runtime path

```text
payments-api
   |
   | GET /metrics
   v
Shared Prometheus
   |
   v
Shared Grafana and alert routing
```

Telemetry does not pass through Argo CD. Argo CD is the deployment reconciler. Prometheus independently discovers and scrapes the ServiceMonitor target.

## Guardrails

Kyverno validates that every Deployment in the `payments` namespace contains a non-empty `platform.example.io/owner` label. This demonstrates admission-time enforcement of platform metadata.

## Local constraints

The workload image is loaded directly into Kind and uses `imagePullPolicy: Never`. A production platform would publish an immutable image to a registry and promote it through environments.
