project_name = "pulpit-v2"
environment  = "dev"
aws_region   = "us-east-1"

availability_zones = [
  "us-east-1a",
  "us-east-1b",
]

enable_nat_gateway = false
single_nat_gateway = true
node_subnet_type   = "public"

node_instance_types = ["t3.medium"]
node_min_size       = 2
node_max_size       = 2
node_desired_size   = 2

github_repository          = "manynames3/pulpit-v2"
create_github_actions_role = true
