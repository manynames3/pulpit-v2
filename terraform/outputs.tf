output "name_prefix" {
  description = "Common name prefix used across resources."
  value       = local.name_prefix
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_oidc_provider_arn" {
  description = "OIDC provider ARN created for IRSA."
  value       = module.eks.oidc_provider_arn
}

output "vpc_id" {
  description = "VPC ID for the cluster."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.networking.private_subnet_ids
}

output "ecr_repository_urls" {
  description = "Map of ECR repository URLs."
  value       = module.ecr.repository_urls
}

output "github_actions_role_arn" {
  description = "Optional GitHub Actions role ARN."
  value       = module.iam.github_actions_role_arn
}
