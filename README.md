# Platform Paved Path

This project demonstrates a small working platform capability: it converts a common deployment request into a repeatable Git-based paved path. It applies shared-platform lessons—metadata, automation, guardrails, ownership, and operational readiness—to Kubernetes delivery.

## Status

Phase 0 complete: repository skeleton and prerequisites.

## Target service

- Service: `payments-api`
- Owner: `payments-team`
- Environment: `dev`
- Namespace: `payments`

## Planned architecture

```text
Deployment path

Developer
   |
   v
GitHub Pull Request --> GitHub Actions CI --> Git desired state
                                                 |
                                                 v
                                           Argo CD
                                                 |
                                                 v
                                          Kubernetes API
                                                 |
                                                 v
                                      payments-api workload


Runtime observability path

payments-api /metrics --> Shared Prometheus --> Grafana
```

Telemetry does not flow through Argo CD. Argo CD reconciles declared Kubernetes resources; Prometheus scrapes the application's runtime metrics endpoint independently.

## Planned capabilities

- FastAPI application with health and metrics endpoints
- Local image build and Kind-based Kubernetes deployment
- Kustomize workload manifests
- Argo CD GitOps reconciliation
- Tenant baseline with namespace labels, ResourceQuota, and LimitRange
- Git-based self-service script for new services
- Kyverno guardrails for ownership and resource configuration
- Drift detection and reconciliation demonstration
- CI validation through GitHub Actions

## Repository layout

```text
platform-paved-path/
├── app/                     # FastAPI application and tests
├── bootstrap/               # Local cluster bootstrap assets
├── platform/
│   ├── argocd/              # Argo CD Application definitions
│   ├── tenants/             # Namespace baseline, quota, limits
│   ├── policies/            # Kyverno policies
│   └── observability/       # ServiceMonitor and PrometheusRule manifests
├── service-template/        # Template consumed by create-service.sh
├── services/payments-api/   # Example service desired state
├── examples/noncompliant/   # Manifests expected to fail policy validation
├── scripts/                 # Self-service and demo helper scripts
├── docs/                    # Architecture, contract, decisions, demo script
└── .github/workflows/       # CI validation workflow
```

## Scope limits

This is a local, single-cluster demonstration using macOS, Docker Desktop, Kind, Kubernetes, Kustomize, Argo CD, and GitHub Actions.

It intentionally does not implement Backstage, Jenkins, Artifactory, Terraform, Crossplane, OpenSearch/Logstash, Slack, ServiceNow, BigPanda, Keycloak, SPIFFE/SPIRE, multi-cluster infrastructure, or production-grade tenant isolation. The documentation will map these components to an enterprise platform environment.

## Next phase

Build the FastAPI service, container image, and validate deployment directly on Kind before introducing GitOps.
