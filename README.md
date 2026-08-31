# WeER GitOps

WeER GitOps owns the declarative deployment layer for the WeER Renewal portfolio project.

This repository is intentionally separate from `weer-pipeline`.

- `weer-pipeline` builds and publishes images, then triggers a GitOps update handoff.
- `weer-gitops` stores Helm values, Kubernetes manifests, Argo CD Applications, and rollout/rollback documentation.
- Argo CD syncs this repository into a local k3s cluster.

## MVP Flow

```text
weer-pipeline
  -> backend/frontend image build
  -> image push
  -> downstream Update K8S Manifest job
  -> update this repo

weer-gitops
  -> Helm values change
  -> Git commit
  -> Argo CD sync
  -> k3s rollout
```

## Structure

```text
.
├── apps/
│   └── argocd/
│       └── weer-local.yaml
├── charts/
│   └── weer/
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── values-local.yaml
│       └── templates/
├── docs/
│   ├── gitops-update-flow.md
│   ├── k3s-argocd-setup.md
│   ├── rollback-runbook.md
│   └── sensitive-values.md
└── scripts/
    └── update-image-tag.sh
```

## Status

Initial GitOps scaffold. Images and hostnames use placeholders until the pipeline and local k3s environment are connected.
