variable "name_prefix" {
  type = string
}

variable "repository_names" {
  type = list(string)
}

variable "image_scan_on_push" {
  type = bool
}

variable "mutable_tags" {
  type = bool
}

variable "force_delete" {
  type = bool
}

variable "tags" {
  type = map(string)
}
