terraform {
  source = "git::https://<Github-PAT-Token>@github.com/infra-modules.git//eks-resources"
}


include "root" {
  path = find_in_parent_folders()
}

include "env"{
  path = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

include "account"{
  path = find_in_parent_folders("account.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

dependency "eks" {
  config_path = "../eks"
  mock_outputs = {eks_cluster_name = "eks_cluster_name", eks_cluster_certificate_authority_data = "eks_cluster_certificate_authority_data", eks_cluster_endpoint = "eks_cluster_endpoint" }
}



inputs = {

  cluster_name         = "eks"
  eks_cluster_endpoint = dependency.eks.outputs.eks_cluster_endpoint
  eks_cluster_name = dependency.eks.outputs.eks_cluster_name
  argo_parent_app = "argo_crds_root_app"
  values_file_name = "values-${include.env.locals.environment_name}.yaml"
  
  subnet_ids = [include.env.locals.eks_controlplane_subnet_az1, include.env.locals.eks_controlplane_subnet_az2]

  environment  = include.env.locals.environment_name
  project_name = "tapplent"

}
