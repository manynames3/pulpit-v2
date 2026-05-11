#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/00-update-kubeconfig.sh"
"${SCRIPT_DIR}/10-install-aws-load-balancer-controller.sh"
"${SCRIPT_DIR}/30-install-external-secrets.sh"
"${SCRIPT_DIR}/40-install-kube-prometheus-stack.sh"
"${SCRIPT_DIR}/20-install-argocd.sh"
"${SCRIPT_DIR}/50-post-install-health-checks.sh"
