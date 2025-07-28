 
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
 
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_region" "current" {}
 
locals{
  cluster_name    = "${var.project_name}-${local.region}-${var.environment}-${var.cluster_name}"
  region          = data.aws_region.current.name
  environment     = var.environment
  project_name = var.project_name
}

data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}
 
data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name
}

