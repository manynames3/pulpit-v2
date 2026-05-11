#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
TERRAFORM_DIR="${TERRAFORM_DIR:-${REPO_ROOT}/terraform}"

default_region_from_tfvars() {
  local tfvars_file="${TERRAFORM_DIR}/environments/dev/dev.tfvars"
  if [[ -f "${tfvars_file}" ]]; then
    awk -F' = ' '/^aws_region/ { gsub(/"/, "", $2); print $2 }' "${tfvars_file}" | head -n1
  fi
}

AWS_REGION="${AWS_REGION:-$(default_region_from_tfvars)}"
AWS_REGION="${AWS_REGION:-us-east-1}"
export AWS_REGION

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

require_base_tools() {
  require_cmd aws
  require_cmd kubectl
  require_cmd helm
  require_cmd terraform
}

cluster_name() {
  if [[ -n "${CLUSTER_NAME:-}" ]]; then
    printf '%s\n' "${CLUSTER_NAME}"
    return
  fi

  local name=""
  if name="$(terraform -chdir="${TERRAFORM_DIR}" output -raw cluster_name 2>/dev/null)"; then
    printf '%s\n' "${name}"
    return
  fi

  printf '%s\n' "pulpit-v2-dev-eks"
}

aws_account_id() {
  aws sts get-caller-identity --query Account --output text
}

vpc_id() {
  aws eks describe-cluster \
    --region "${AWS_REGION}" \
    --name "$(cluster_name)" \
    --query 'cluster.resourcesVpcConfig.vpcId' \
    --output text
}

timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

log() {
  printf '[%s] %s\n' "$(timestamp)" "$*"
}
