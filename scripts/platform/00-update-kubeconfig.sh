#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_base_tools

CLUSTER="$(cluster_name)"
log "Updating kubeconfig for ${CLUSTER} in ${AWS_REGION}"
aws eks update-kubeconfig --region "${AWS_REGION}" --name "${CLUSTER}" >/dev/null

log "Current kubectl context"
kubectl config current-context

log "Cluster nodes"
kubectl get nodes -o wide
