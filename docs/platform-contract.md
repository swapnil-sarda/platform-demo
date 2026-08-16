# Platform Contract

## Service input

Application teams provide:

- Service name: lowercase DNS label, for example `orders-api`
- Owner team: lowercase label, for example `orders-team`
- Git change containing the generated service configuration

Use:

```bash
./scripts/create-service.sh <service-name> <owner-team>
```

## Required metadata

Every supported workload uses:

```yaml
app.kubernetes.io/name: <service-name>
platform.example.io/owner: <owner-team>
platform.example.io/environment: dev
platform.example.io/criticality: tier-2
```

The owner label is enforced by Kyverno for Deployments in the `payments` namespace.

## Workload defaults

The template provides:

- Two replicas
- HTTP Service on port 80 to target port 8080
- Readiness and liveness probes at `/healthz`
- CPU request: `100m`
- Memory request: `128Mi`
- CPU limit: `250m`
- Memory limit: `256Mi`

## Tenant baseline

The `payments` tenant demonstrates basic shared-cluster controls:

- Namespace ownership and environment labels
- ResourceQuota
- LimitRange defaults

This is not full tenant isolation. Production isolation would also consider network segmentation, identity, Pod Security Admission, RBAC, secrets management, and environment-specific controls.

## Observability contract

A supported service should expose:

```text
GET /healthz
GET /metrics
```

The shared platform can consume the provided ServiceMonitor and PrometheusRule manifests when Prometheus Operator is available.

## Delivery contract

- Git is the source of truth
- CI validates tests, image build, and rendered manifests
- Argo CD reconciles Git desired state
- Manual sync is retained in this demo to make drift visible
