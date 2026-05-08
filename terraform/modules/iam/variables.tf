variable "create_github_actions_role" {
  type = bool
}

variable "github_repository" {
  type = string
}

variable "role_name" {
  type = string
}

variable "tags" {
  type = map(string)
}
