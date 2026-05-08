output "github_actions_role_arn" {
  value = var.create_github_actions_role ? aws_iam_role.github_actions[0].arn : null
}

output "github_actions_oidc_provider_arn" {
  value = var.create_github_actions_role ? aws_iam_openid_connect_provider.github_actions[0].arn : null
}

output "github_actions_ecr_policy_arn" {
  value = var.create_github_actions_role ? aws_iam_policy.github_actions_ecr[0].arn : null
}
