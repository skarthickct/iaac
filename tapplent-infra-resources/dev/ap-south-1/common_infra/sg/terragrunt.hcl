
terraform {
  source = "git::https://<Github-PAT-Token>@github.com/AWS-CICD-ASISTA/asista-infra-modules.git//sg"
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

# dependency "vpc" {
#  config_path = "../vpc"  # Adjust the relative path to your VPC module
# }

# Define input variables
inputs = {
  environment = include.env.locals.environment_name # Adjust as per your environment
  region      = include.env.locals.region           # Set your desired AWS region
  # subnet_ids  = include.env.locals.subnet_ids

  vpc_id      = include.env.locals.vpc_id                  # Replace with your VPC ID
}