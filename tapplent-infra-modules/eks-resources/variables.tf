variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "project_name" {
  description = "name of the project to refer on the cluster name"
  type        = string
}

