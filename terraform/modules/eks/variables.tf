variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "cluster_subnet_ids" {
  type = list(string)
}

variable "node_subnet_ids" {
  type = list(string)
}

variable "cluster_endpoint_public_access" {
  type = bool
}

variable "node_instance_types" {
  type = list(string)
}

variable "node_capacity_type" {
  type = string
}

variable "node_min_size" {
  type = number
}

variable "node_max_size" {
  type = number
}

variable "node_desired_size" {
  type = number
}

variable "tags" {
  type = map(string)
}
