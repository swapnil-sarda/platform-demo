# Platform Paved Path

This project demonstrates a small working platform capability: it converts a common deployment request into a repeatable Git-based paved path. It applies shared-platform lessons—metadata, automation, guardrails, ownership, and operational readiness—to Kubernetes delivery.

The example service is `payments-api`, owned by `payments-team`.

## Problem

Application teams previously raised tickets for namespaces, deployment configuration, labels, resources, monitoring, and alerts. This project provides a standard Git-based route instead:

- A reusable template creates supported service configuration
- Git stores the desired state
- GitHub Actions validates application code and Kubernetes manifests
- Argo CD reconciles Git desired state into Kubernetes
- Kyverno enforces ownership metadata
- A small tenant baseline provides quotas and defaults
- Metrics and monitoring manifests support a shared observability platform

## Architecture

```text
Deployment path

Developer
   |
   v
GitHub pull request
   |
   v
GitHub Actions CI
   |
   v
Git desired state
   |
   v
Argo CD
   |
   v
Kubernetes API
   |
   v
payments-api Deployment and Service


Runtime observability path

payments-api /metrics
   |
   v
Shared Prometheus
   |
   v
Shared Grafana
```

Telemetry does not flow through Argo CD. Argo CD reconciles Kubernetes desired state; Prometheus independently scrapes the application's `/metrics` endpoint.

## Prerequisites

- macOS
- Docker Desktop
- Kind
- kubectl
- Helm
- Git
- GitHub CLI
- Python 3
- Argo CD CLI

## Quick start

```bash
git clone https://github.com/<your-user>/platform-demo.git
cd platform-demo

docker build -t payments-api:dev app

kind create cluster --config bootstrap/kind-config.yaml
kind load docker-image payments-api:dev --name platform-paved-path

kubectl apply -f bootstrap/payments-api-direct.yaml
kubectl rollout status deployment/payments-api -n payments
```

The direct manifest is only a Phase 1 bootstrap validation. The intended deployment method is Argo CD reconciliation from `services/payments-api`.

## Repository layout

```text
app/                         FastAPI service, tests, Dockerfile
bootstrap/                   Kind cluster configuration
platform/argocd/             Argo CD Application resources
platform/tenants/            Namespace baseline, quota, limits
platform/policies/           Kyverno policy
platform/observability/      ServiceMonitor and PrometheusRule contracts
service-template/            Reusable service manifest template
services/payments-api/       GitOps desired state for the example service
examples/noncompliant/       Manifest intentionally rejected by policy
scripts/                     Self-service service creation script
docs/                        Architecture, contract, decisions, demo guide
.github/workflows/           CI validation workflow
```

## Self-service flow

Create a standard service configuration:

```bash
./scripts/create-service.sh orders-api orders-team
kubectl kustomize services/orders-api
```

The script creates `services/orders-api/` from `service-template/`, replaces the service and owner placeholders, and prints the next Git steps. It does not create a pull request automatically.

## GitOps flow

`platform/argocd/payments-api-application.yaml` tells Argo CD to watch:

```text
Repository: GitHub repository
Revision: main
Path: services/payments-api
```

The workload uses:

- Namespace: `payments`
- Replicas: `2`
- Readiness and liveness probes: `/healthz`
- Resource requests and limits
- Standard ownership, environment, and criticality labels
- Local Kind image: `payments-api:dev` with `imagePullPolicy: Never`

## Drift demo

1. Confirm GitOps is healthy:

   ```bash
   argocd app get payments-api
   ```

2. Introduce live drift:

   ```bash
   kubectl scale deployment payments-api -n payments --replicas=5
   ```

3. Refresh Argo CD state:

   ```bash
   argocd app get payments-api --refresh
   ```

   Expected: `OutOfSync`.

4. Reconcile desired state:

   ```bash
   argocd app sync payments-api
   argocd app wait payments-api --sync --health --timeout 180
   ```

5. Confirm Git desired state wins:

   ```bash
   kubectl get deployment payments-api -n payments \
     -o jsonpath='{.spec.replicas} desired, {.status.availableReplicas} available{"\n"}'
   ```

   Expected: `2 desired, 2 available`.

## Policy demo

Kyverno enforces a non-empty `platform.example.io/owner` label for Deployments in `payments`.

```bash
kubectl apply --dry-run=server \
  -f examples/noncompliant/missing-owner-deployment.yaml
```

Expected: admission is denied by `require-platform-owner-label`.

## Observability

The app exposes:

```text
GET /metrics
```

`platform/observability/` contains:

- A `ServiceMonitor` that selects the `payments-api` Service
- A `PrometheusRule` that alerts when the target remains unavailable for five minutes

These manifests are rendered locally but not applied because this Kind demo does not install Prometheus Operator, Prometheus, or Grafana.

## Enterprise mapping

| Demo component | Enterprise mapping |
|---|---|
| `create-service.sh` | Backstage template or self-service portal action |
| GitHub Actions | Shared Jenkins templates or enterprise CI |
| Local Kind image | Image built and published to Artifactory or a container registry |
| Argo CD Application | Shared Argo CD platform with environment promotion |
| Namespace quota and limits | Tenant onboarding baseline managed by platform automation |
| Kyverno label policy | Policy-as-code guardrails and compliance controls |
| ServiceMonitor and PrometheusRule | Shared Prometheus, Grafana, alert routing, and ownership-based operations |
| Standard labels | Ownership, routing, cost allocation, service inventory, and operational context |
