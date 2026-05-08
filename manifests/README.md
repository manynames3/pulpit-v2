# Kubernetes Manifests

This directory holds GitOps-managed manifests for:

- namespaces
- ArgoCD applications
- tenant-specific resources

Layout:

- `argocd/`
  - ArgoCD namespace, project, root app, and child application manifests
- `namespaces/`
  - shared and tenant namespace definitions
- `tenants/`
  - per-tenant foundational manifests such as `ResourceQuota` and `LimitRange`
