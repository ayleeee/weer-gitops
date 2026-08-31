# k3s and Argo CD Setup

## Goal

Run the WeER Renewal backend on a local k3s cluster using Argo CD and Helm.

Frontend delivery is handled by the Jenkins static-site pipeline through S3 and optional CloudFront invalidation.

## Planned Steps

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f apps/argocd/weer-local.yaml
```

## Local Hostname

Use a local hostname such as:

```text
weer.local
```

Map it to the local ingress endpoint during local testing.

## Evidence To Capture

- `kubectl get nodes`
- `kubectl get pods -n argocd`
- `kubectl get application -n argocd`
- `kubectl get deploy,svc,ingress -n weer`
- Argo CD sync status
- rollout status for backend
