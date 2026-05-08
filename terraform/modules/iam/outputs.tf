output "github_actions_role_arn" {
  value = var.create_github_actions_role ? aws_iam_role.github_actions[0].arn : null
}
