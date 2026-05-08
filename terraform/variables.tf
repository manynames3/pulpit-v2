variable "project_name" {
  description = "Project slug used in resource names."
  type        = string
  default     = "pulpit-v2"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for the V2 platform."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name_override" {
  description = "Optional explicit EKS cluster name."
  type        = string
  default     = null
}

variable "availability_zones" {
  description = "Availability zones for the VPC."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.42.0.0/20", "10.42.16.0/20"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets."
  type        = list(string)
  default     = ["10.42.128.0/20", "10.42.144.0/20"]
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT gateways for private subnet egress."
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT gateway when NAT is enabled."
  type        = bool
  default     = true
}

variable "node_subnet_type" {
  description = "Subnet type for worker nodes: public or private."
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private"], var.node_subnet_type)
    error_message = "node_subnet_type must be either public or private."
  }
}

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.35"
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS API endpoint is publicly accessible."
  type        = bool
  default     = true
}

variable "node_instance_types" {
  description = "EC2 instance types for the default managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "Capacity type for the managed node group."
  type        = string
  default     = "ON_DEMAND"
}

variable "node_min_size" {
  description = "Minimum node count for the managed node group."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum node count for the managed node group."
  type        = number
  default     = 2
}

variable "node_desired_size" {
  description = "Desired node count for the managed node group."
  type        = number
  default     = 2
}

variable "ecr_repository_names" {
  description = "Logical service repository names to create in ECR."
  type        = list(string)
  default     = ["api-service", "query-service", "ingest-service"]
}

variable "ecr_image_scan_on_push" {
  description = "Enable ECR image scanning on push."
  type        = bool
  default     = true
}

variable "ecr_mutable_tags" {
  description = "Whether ECR tags are mutable."
  type        = bool
  default     = true
}

variable "ecr_force_delete" {
  description = "Allow ECR repositories to be force deleted with images."
  type        = bool
  default     = true
}

variable "create_github_actions_role" {
  description = "Whether to create a GitHub Actions OIDC role scaffold."
  type        = bool
  default     = false
}

variable "github_repository" {
  description = "GitHub repository in owner/name form for OIDC trust."
  type        = string
  default     = "manynames3/pulpit-v2"
}

variable "tags" {
  description = "Additional tags applied to resources."
  type        = map(string)
  default     = {}
}
