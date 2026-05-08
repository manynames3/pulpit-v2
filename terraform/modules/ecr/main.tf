locals {
  repositories = {
    for repo_name in var.repository_names :
    repo_name => "${var.name_prefix}/${repo_name}"
  }
}

resource "aws_ecr_repository" "this" {
  for_each = local.repositories

  name                 = each.value
  image_tag_mutability = var.mutable_tags ? "MUTABLE" : "IMMUTABLE"
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.image_scan_on_push
  }

  tags = merge(var.tags, {
    Service = each.key
  })
}
