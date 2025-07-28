# Terragrunt configuration to generate provider.tf and state.tf

# Generating the AWS provider configuration

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "aws" {
  region  = "ap-south-1"
  assume_role {
      session_name = "terraform"
      role_arn = "arn:aws:iam::842676005771:role/terraform-assumed-role-shared"
    }
}
EOF
} 

remote_state {
  backend = "s3"
  generate = {
    path      = "state.tf"
    if_exists = "overwrite_terragrunt"
  }

config = {
    bucket         = "tapplent-terraform-state-dev2" 
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-south-1" 
    encrypt        = true
    dynamodb_table = "terraform-lock-table" 
    role_arn = "arn:aws:iam::842676005771:role/terraform-assumed-role-shared"
  }
}