#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_base_tools

VALUES_FILE="${KUBE_PROM_VALUES_FILE:-${SCRIPT_DIR}/values/kube-prometheus-stack-demo.yaml}"
CHART_VERSION="${KUBE_PROMETHEUS_STACK_CHART_VERSION:-}"
DASHBOARD_FILE="${REPO_ROOT}/helm/observability/dashboards/pulpit-v2-overview.json"

log "Installing kube-prometheus-stack"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
helm repo update prometheus-community >/dev/null

HELM_ARGS=(
  upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack
  --namespace observability
  --create-namespace
  --values "${VALUES_FILE}"
  --wait
  --timeout 15m
)

if [[ -n "${CHART_VERSION}" ]]; then
  HELM_ARGS+=(--version "${CHART_VERSION}")
fi

helm "${HELM_ARGS[@]}"

log "Publishing Grafana dashboard configmap"
kubectl create configmap pulpit-v2-overview-dashboard \
  -n observability \
  --from-file=pulpit-v2-overview.json="${DASHBOARD_FILE}" \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl label configmap pulpit-v2-overview-dashboard -n observability grafana_dashboard=1 --overwrite

log "Prometheus operator deployment status"
kubectl rollout status deployment/kube-prometheus-stack-operator -n observability --timeout=5m
