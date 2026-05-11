#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_base_tools
require_cmd eksctl

CLUSTER="$(cluster_name)"
ACCOUNT_ID="$(aws_account_id)"
POLICY_NAME="${EXTERNAL_SECRETS_POLICY_NAME:-PulpitV2ExternalSecretsSSMRead-${CLUSTER}}"
ROLE_NAME="${EXTERNAL_SECRETS_ROLE_NAME:-pulpit-v2-external-secrets-${CLUSTER}}"
VALUES_FILE="${EXTERNAL_SECRETS_VALUES_FILE:-${SCRIPT_DIR}/values/external-secrets-demo.yaml}"
CHART_VERSION="${EXTERNAL_SECRETS_CHART_VERSION:-}"

TMP_POLICY="$(mktemp)"
trap 'rm -f "${TMP_POLICY}"' EXIT

cat > "${TMP_POLICY}" <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeParameters",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ],
      "Resource": "arn:aws:ssm:${AWS_REGION}:${ACCOUNT_ID}:parameter/pulpit-v2/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "*"
    }
  ]
}
EOF

POLICY_ARN="$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='${POLICY_NAME}'].Arn | [0]" --output text)"
if [[ -z "${POLICY_ARN}" || "${POLICY_ARN}" == "None" ]]; then
  log "Creating IAM policy ${POLICY_NAME}"
  POLICY_ARN="$(aws iam create-policy --policy-name "${POLICY_NAME}" --policy-document "file://${TMP_POLICY}" --query 'Policy.Arn' --output text)"
else
  log "Reusing IAM policy ${POLICY_NAME}"
fi

log "Creating or updating IAM service account for External Secrets"
eksctl create iamserviceaccount \
  --cluster "${CLUSTER}" \
  --region "${AWS_REGION}" \
  --namespace external-secrets \
  --name external-secrets \
  --role-name "${ROLE_NAME}" \
  --attach-policy-arn "${POLICY_ARN}" \
  --override-existing-serviceaccounts \
  --approve

log "Installing External Secrets Operator"
helm repo add external-secrets https://charts.external-secrets.io >/dev/null
helm repo update external-secrets >/dev/null

HELM_ARGS=(
  upgrade --install external-secrets external-secrets/external-secrets
  --namespace external-secrets
  --create-namespace
  --values "${VALUES_FILE}"
  --wait
  --timeout 10m
)

if [[ -n "${CHART_VERSION}" ]]; then
  HELM_ARGS+=(--version "${CHART_VERSION}")
fi

helm "${HELM_ARGS[@]}"

log "Applying ClusterSecretStore for AWS Parameter Store"
cat <<EOF | kubectl apply -f -
apiVersion: external-secrets.io/v1
kind: ClusterSecretStore
metadata:
  name: aws-parameter-store
spec:
  provider:
    aws:
      service: ParameterStore
      region: ${AWS_REGION}
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets
            namespace: external-secrets
EOF

log "External Secrets deployment status"
kubectl rollout status deployment/external-secrets -n external-secrets --timeout=5m
