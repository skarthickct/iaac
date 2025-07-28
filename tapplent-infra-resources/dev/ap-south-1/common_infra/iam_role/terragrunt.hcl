
terraform {
  source = "git::https://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@github.com/tapplent-infra-modules/iam_role"
}

# Include the parent configuration
include "root" {
  path = find_in_parent_folders()
}
 
include "env" {
  path = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

include "account" {
  path = find_in_parent_folders("account.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

dependency "eks" {
  config_path = "..//eks"  
}

inputs = {
  role_name       = include.env.locals.role_name 
  policy_name     = include.env.locals.policy_name 
  profile_name    = include.env.locals.profile_name
  cluster_arn     = "arn:aws:iam::${include.account.locals.aws_account_number}:role/${dependency.eks.outputs.cluster_iam_role_name}"
  irsa_oidc_provider_arn = dependency.eks.outputs.oidc_provider_arn
  cluster_name    =  dependency.eks.outputs.eks_cluster_name
}
