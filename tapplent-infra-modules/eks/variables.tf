variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}


variable "environment" {
  description = "Environment name."
  type        = string
}

variable "service_name" {
  description = "name of the service to add in tags"
  type        = string
}


variable "launched_by" {
  description = "name of the user who is launching the cluster for adding in tags"
  type        = string
}


variable "team_name" {
  description = "name of the team to add in tags"
  type        = string
}

variable "cluster_version" {
  description = "version of the cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster security group will be provisioned"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs. Must be in at least two different availability zones."
  type        = list(string)
}

variable "control_plane_subnet_ids" {
  description = "A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned. Used for expanding the pool of subnets used by nodes/node groups without replacing the EKS control plane"
  type        = list(string)
}

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions to create"
  type        = any
  default     = {}
}

variable "project_name" {
  description = "name of the project to refer on the cluster name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR range"
  type        = list(string)
}