#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_base_tools

log "Cluster info"
kubectl cluster-info

log "Nodes"
kubectl get nodes -o wide

log "Key namespaces"
kubectl get ns argocd external-secrets observability bethel-atlanta demo-church

log "ArgoCD pods and applications"
kubectl get pods -n argocd
kubectl get applications -n argocd

log "External Secrets pods and stores"
kubectl get pods -n external-secrets
kubectl get clustersecretstore
kubectl get externalsecret -A

log "Observability pods and monitoring objects"
kubectl get pods -n observability
kubectl get servicemonitors,prometheusrules -A

log "Tenant workloads"
kubectl get pods -n bethel-atlanta
kubectl get pods -n demo-church
kubectl get ingress -A
kubectl get cronjobs -A

log "Recent warning events"
kubectl get events -A --field-selector type=Warning --sort-by=.lastTimestamp | tail -n 40 || true
