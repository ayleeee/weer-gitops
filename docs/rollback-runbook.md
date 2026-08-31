# Rollback Runbook

## Purpose

Describe how to recover from a bad image update in the GitOps flow.

## Scenario

A backend image tag is updated in `charts/weer/values-local.yaml`, Argo CD syncs it, and the rollout fails.

## Recovery Options

### Option 1 - Git Revert

Use when the last GitOps commit introduced the bad image tag.

```bash
git revert <bad-gitops-commit-sha>
git push
```

Argo CD should detect the revert and sync the previous known-good image.

### Option 2 - Forward Fix

Use when a newer good image exists.

```bash
scripts/update-image-tag.sh backend registry.example.com/weer/backend <known-good-tag>
git add charts/weer/values-local.yaml
git commit -m "fix(gitops): restore backend image to <known-good-tag>"
git push
```

## Evidence To Capture

- bad GitOps commit SHA
- Argo CD sync status
- failing Pod Events
- rollback or forward-fix commit SHA
- final rollout status
