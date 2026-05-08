locals {
  name_prefix  = "${var.project_name}-${var.environment}"
  cluster_name = coalesce(var.cluster_name_override, "${local.name_prefix}-eks")

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Repository  = "manynames3/pulpit-v2"
    },
    var.tags
  )

  cluster_subnet_ids = concat(
    module.networking.public_subnet_ids,
    module.networking.private_subnet_ids
  )

  node_subnet_ids = var.node_subnet_type == "private" ? module.networking.private_subnet_ids : module.networking.public_subnet_ids
}

module "networking" {
  source = "./modules/networking"

  name_prefix          = local.name_prefix
  cluster_name         = local.cluster_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  tags                 = local.common_tags
}

module "ecr" {
  source = "./modules/ecr"

  name_prefix        = local.name_prefix
  repository_names   = var.ecr_repository_names
  image_scan_on_push = var.ecr_image_scan_on_push
  mutable_tags       = var.ecr_mutable_tags
  force_delete       = var.ecr_force_delete
  tags               = local.common_tags
}

module "iam" {
  source = "./modules/iam"

  create_github_actions_role = var.create_github_actions_role
  github_repository          = var.github_repository
  role_name                  = "${local.name_prefix}-github-actions"
  tags                       = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name                   = local.cluster_name
  cluster_version                = var.eks_cluster_version
  cluster_subnet_ids             = local.cluster_subnet_ids
  node_subnet_ids                = local.node_subnet_ids
  vpc_id                         = module.networking.vpc_id
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  node_instance_types            = var.node_instance_types
  node_capacity_type             = var.node_capacity_type
  node_min_size                  = var.node_min_size
  node_max_size                  = var.node_max_size
  node_desired_size              = var.node_desired_size
  tags                           = local.common_tags
}
