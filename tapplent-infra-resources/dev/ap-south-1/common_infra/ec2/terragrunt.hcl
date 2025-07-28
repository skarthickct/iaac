terraform {
  source = "git::https://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@github.com/tapplent-infra-modules/ec2/main.tf"
}

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
#   config_path = "../../vpc"  # Adjust the relative path to your VPC module
# }

dependency "sg" {
  config_path = "../sg"  
}

# dependency "iam_role" {
#   config_path = "../iam_role"  
# }



inputs = {
  instance_name       = include.env.locals.bastion_host_name
  instance_type       = include.env.locals.instance_type 
  userdata            = include.env.locals.user_data
  subnet_ids           = include.env.locals.subnet_ids  
  key_name              =  include.env.locals.key_name 
  iam_profile            =  include.env.locals.profile_name
  volume_type           =  include.env.locals.volume_type
  volume_size           =  include.env.locals.volume_size
  delete_with_instance   = true
  
  security_group_ids =  [dependency.sg.outputs.bastion_host_sg]

  ami_id              = include.env.locals.ami_id 
  region              = include.env.locals.region
}