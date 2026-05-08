module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.36"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.cluster_subnet_ids

  cluster_endpoint_public_access = var.cluster_endpoint_public_access

  enable_irsa                              = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns      = {}
    "kube-proxy" = {}
    "vpc-cni"    = {}
  }

  eks_managed_node_groups = {
    default = {
      name           = "default"
      subnet_ids     = var.node_subnet_ids
      instance_types = var.node_instance_types
      capacity_type  = var.node_capacity_type
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      desired_size   = var.node_desired_size

      labels = {
        workload = "general"
      }
    }
  }

  tags = var.tags
}
