

variable "vpc_id" {
  description = "The VPC ID where the EFS will be created."
  type        = string
}

variable "environment" {
  description = "The environment for which the resources are being created (e.g., dev, staging, prod)."
  type        = string
}

