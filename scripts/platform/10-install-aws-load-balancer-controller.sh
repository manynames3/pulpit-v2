#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_base_tools
require_cmd eksctl
require_cmd curl

CLUSTER="$(cluster_name)"
ACCOUNT_ID="$(aws_account_id)"
VPC_ID="$(vpc_id)"
POLICY_NAME="${ALB_IAM_POLICY_NAME:-AWSLoadBalancerControllerIAMPolicy-${CLUSTER}}"
ROLE_NAME="${ALB_ROLE_NAME:-AmazonEKSLoadBalancerControllerRole-${CLUSTER}}"
POLICY_DOC_URL="${ALB_IAM_POLICY_URL:-https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json}"
CHART_VERSION="${ALB_CONTROLLER_CHART_VERSION:-}"

TMP_POLICY="$(mktemp)"
trap 'rm -f "${TMP_POLICY}"' EXIT

log "Downloading ALB controller IAM policy document"
curl -fsSL "${POLICY_DOC_URL}" -o "${TMP_POLICY}"

POLICY_ARN="$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='${POLICY_NAME}'].Arn | [0]" --output text)"
if [[ -z "${POLICY_ARN}" || "${POLICY_ARN}" == "None" ]]; then
  log "Creating IAM policy ${POLICY_NAME}"
  POLICY_ARN="$(aws iam create-policy --policy-name "${POLICY_NAME}" --policy-document "file://${TMP_POLICY}" --query 'Policy.Arn' --output text)"
else
  log "Reusing IAM policy ${POLICY_NAME}"
fi

log "Creating or updating IAM service account for ALB controller"
eksctl create iamserviceaccount \
  --cluster "${CLUSTER}" \
  --region "${AWS_REGION}" \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --role-name "${ROLE_NAME}" \
  --attach-policy-arn "${POLICY_ARN}" \
  --override-existing-serviceaccounts \
  --approve

log "Installing aws-load-balancer-controller via Helm"
helm repo add eks https://aws.github.io/eks-charts >/dev/null
helm repo update eks >/dev/null

HELM_ARGS=(
  upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller
  --namespace kube-system
  --set clusterName="${CLUSTER}"
  --set serviceAccount.create=false
  --set serviceAccount.name=aws-load-balancer-controller
  --set region="${AWS_REGION}"
  --set vpcId="${VPC_ID}"
  --wait
  --timeout 10m
)

if [[ -n "${CHART_VERSION}" ]]; then
  HELM_ARGS+=(--version "${CHART_VERSION}")
fi

helm "${HELM_ARGS[@]}"

log "ALB controller deployment status"
kubectl rollout status deployment/aws-load-balancer-controller -n kube-system --timeout=5m
