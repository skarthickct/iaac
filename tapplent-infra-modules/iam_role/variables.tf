variable "role_name" {
  type = string
  description = "Name for the bastion host IAM role"
}

variable "policy_name" {
  type = string
  description = "bastion host policy name"
}


variable "profile_name" {
  type = string
  description = "Bastion host profile arn"
}

variable "cluster_arn" {
  type = string
  description = "EKS cluster arn"
}

variable "cluster_name" {
  type = string
  description = "cluster name"
}

variable "irsa_oidc_provider_arn" {
  description = "OIDC provider arn used in trust policy for IAM role for service accounts"
  type        = string
  default     = ""
}

variable "irsa_namespace_service_accounts_karpenter" {
  description = "List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts"
  type        = list(string)
  default     = ["kube-system:karpenter"]
}

variable "irsa_namespace_service_accounts_loadbalancer" {
  description = "List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts"
  type        = list(string)
  default     = ["kube-system:alb-controller-sa"]
}

variable "irsa_namespace_service_accounts_cloud_controller" {
  description = "List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts"
  type        = list(string)
  default     = ["asista-apps:cloud-controller-sa"]
}

variable "irsa_namespace_service_accounts_s3_loki_role" {
  description = "List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts"
  type        = list(string)
  default     = ["monitoring:loki-distributed"]
}

variable "irsa_namespace_service_accounts_ebs_csi" {
  description = "List of `namespace:serviceaccount`pairs to use in trust policy for IAM role for service accounts"
  type        = list(string)
  default     = ["kube-system:ebs-csi-controller-sa"]
}