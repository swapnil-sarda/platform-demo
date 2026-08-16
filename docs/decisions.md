# Decisions

## One repository

Decision: keep application code, service manifests, platform configuration, policies, and documentation in one repository.

Reason: this is a small interview project. A single repository reduces setup time and makes the end-to-end delivery path easy to demonstrate.

Trade-off: a production platform would often separate application repositories, platform configuration, reusable templates, and environment promotion repositories.

## Kind and local images

Decision: use Kind and load `payments-api:dev` directly into the cluster.

Reason: no registry credentials, image registry, or cloud account are required.

Trade-off: this is local-only. A production platform would publish immutable images to Artifactory, ECR, GHCR, or another registry.

## Kustomize

Decision: use Kustomize for workload manifests.

Reason: native kubectl support and a small, readable configuration model fit the project scope.

## Argo CD manual sync

Decision: configure manual sync.

Reason: it makes live drift visible for the mandatory demonstration. Scaling from 2 to 5 replicas produces `OutOfSync`, then Argo CD manually restores the declared state.

Trade-off: production environments may enable controlled automated sync and self-heal, depending on risk tolerance.

## Tenant baseline

Decision: use Namespace labels, ResourceQuota, and LimitRange.

Reason: they provide a small but concrete demonstration of shared-cluster tenancy controls.

Trade-off: this is not full isolation. NetworkPolicy, RBAC, Pod Security Admission, secrets, identity, and environment boundaries are outside this project.

## Kyverno policy scope

Decision: enforce one owner-label policy in the `payments` namespace.

Reason: ownership metadata is central to alert routing, operational context, and accountability. One working enforced policy is more valuable than several untested policies.

Trade-off: a production policy set would also require resource requests and limits, approved registries, image signatures, workload security controls, and exception workflows.

## Observability scope

Decision: provide `/metrics`, ServiceMonitor, and PrometheusRule manifests without installing Prometheus/Grafana locally.

Reason: the runtime contract is demonstrated while preserving time for GitOps, drift, policy, and documentation.

Trade-off: the monitoring manifests are intended for a shared Prometheus/Grafana platform and are not applied to this Kind cluster.
