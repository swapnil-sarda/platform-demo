# Demo Script

## 1. Start with the platform problem

"Application teams previously opened tickets for a namespace, deployment configuration, metadata, resource limits, monitoring, and alerts. This project converts that request into a repeatable Git-based paved path."

## 2. Show self-service

```bash
./scripts/create-service.sh invoices-api invoices-team
kubectl kustomize services/invoices-api
rm -rf services/invoices-api
```

Explain that the script creates a supported service configuration without a ticket or custom YAML written from scratch.

## 3. Show CI and GitOps

```bash
argocd app get payments-api
```

Show:

```text
Sync Status: Synced
Health Status: Healthy
```

Explain that GitHub Actions validates tests, image build, and rendered manifests. Argo CD then reconciles Git desired state into Kubernetes.

## 4. Show workload readiness

```bash
kubectl get deployment,pods,service -n payments

kubectl get deployment payments-api -n payments \
  -o jsonpath='{.spec.replicas} desired, {.status.availableReplicas} available{"\n"}'
```

Expected:

```text
2 desired, 2 available
```

## 5. Show tenant baseline

```bash
kubectl get namespace payments --show-labels
kubectl get resourcequota,limitrange -n payments
```

Explain that this is a small multi-tenancy demonstration, not full production isolation.

## 6. Show drift detection

```bash
kubectl scale deployment payments-api -n payments --replicas=5
kubectl rollout status deployment/payments-api -n payments --timeout=180s
argocd app get payments-api --refresh
```

Show `OutOfSync`, then reconcile:

```bash
argocd app sync payments-api
argocd app wait payments-api --sync --health --timeout 180
```

Confirm:

```bash
kubectl get deployment payments-api -n payments \
  -o jsonpath='{.spec.replicas} desired, {.status.availableReplicas} available{"\n"}'
```

Expected:

```text
2 desired, 2 available
```

## 7. Show policy enforcement

```bash
kubectl apply --dry-run=server \
  -f examples/noncompliant/missing-owner-deployment.yaml
```

Explain that Kyverno rejects the Deployment because it lacks `platform.example.io/owner`.

## 8. Show observability contract

```bash
kubectl port-forward service/payments-api 8080:80 -n payments
```

In another terminal:

```bash
curl -s http://localhost:8080/metrics | grep payments_api_requests_total
kubectl kustomize platform/observability
```

Explain that telemetry flows directly from the application to shared Prometheus/Grafana, not through Argo CD.
