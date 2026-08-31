# GitOps Update Flow

## Purpose

This document owns the GitOps side of the WeER Renewal deployment flow.

`weer-pipeline` builds and publishes the backend image. This repository receives backend image metadata and turns it into declarative deployment state.

The frontend is delivered separately as a React static build uploaded to S3, with optional CloudFront invalidation. It is not part of the k3s GitOps MVP.

## Flow

```text
Jenkins backend pipeline
  -> image pushed
  -> downstream Update K8S Manifest job receives image metadata
  -> this repo is checked out
  -> charts/weer/values-local.yaml is updated
  -> commit and push
  -> Argo CD detects the change
  -> Argo CD syncs chart to k3s
```

## Inputs From Jenkins

- `SERVICE_NAME`: `weer-backend`
- `IMAGE_REPOSITORY`
- `IMAGE_TAG`
- `IMAGE_DIGEST`
- `SOURCE_COMMIT`
- `UPSTREAM_BUILD_URL`

## Update Target

MVP update target:

```text
charts/weer/values-local.yaml
```

Backend image:

```yaml
backend:
  image:
    repository: registry.example.com/weer/backend
    tag: "..."
```

Frontend image values may remain in the chart for a future container-based variant, but the default MVP keeps `frontend.enabled: false`.

## Commit Message

```text
chore(gitops): update weer-backend image to weer-backend-42-a1b2c3d
```

## Traceability

Each GitOps update should preserve:

- source commit SHA
- Jenkins build URL
- image repository
- image tag
- image digest
- GitOps commit SHA

## Failure Modes

- image was pushed but GitOps update failed
- GitOps repo update conflicted with another deployment
- Argo CD sync failed
- rollout failed after sync

Each failure should be handled as a separate runbook entry instead of hiding it inside the app build job.
