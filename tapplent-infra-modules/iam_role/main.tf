data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  dns_suffix = data.aws_partition.current.dns_suffix
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name
}

locals {
  irsa_oidc_provider_url = replace(var.irsa_oidc_provider_arn, "/^(.*provider/)/", "")
}

############################################################################


resource "aws_iam_role" "bastion_host_role" {
  name = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com",
          AWS = tolist(data.aws_iam_roles.roles.arns)[0]
        }
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "admin_policy" {
  role      = aws_iam_role.bastion_host_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


resource "aws_iam_role_policy_attachment" "cluster_access_policy" {
  role      = aws_iam_role.bastion_host_role.name
  policy_arn = aws_iam_policy.cluster_access_policy.arn
}



resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role      = aws_iam_role.bastion_host_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_policy" "cluster_access_policy" {
  name = var.policy_name
  policy = jsonencode({
    Version = "2012-10-17"
        Statement = [
            {
            Action   = ["eks:DescribeCluster", "eks:ListClusters", "ec2:DescribeInstances", "ec2:DescribeRegions"]
            Effect   = "Allow"
            Resource = "*"
            },
            {
            Action   = ["sts:AssumeRole"]
            Effect   = "Allow"
            Resource = var.cluster_arn                           #data.aws_eks_cluster.cluster.role_arn
            },
        ]
  })
}


data "aws_iam_roles" "roles" {
  name_regex  = "AWSReservedSSO_AWSAdministratorAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/ap-south-1/"
}


resource "aws_iam_instance_profile" "instance_profile" {
  name = var.profile_name
  role = aws_iam_role.bastion_host_role.name
}

#########################################################################
################   Karepenter Controller IAM Role       #################
#########################################################################

resource "aws_iam_role" "karpenter_controller" {
  name = "KarpenterControllerRole-${var.cluster_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRoleWithWebIdentity"]
        Effect = "Allow"
        Principal = {
          Federated = var.irsa_oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${local.irsa_oidc_provider_url}:sub" = [for sa in var.irsa_namespace_service_accounts_karpenter : "system:serviceaccount:${sa}"]
            "${local.irsa_oidc_provider_url}:aud" = ["sts.amazonaws.com"]
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "karpenter_controller_policy" {
  name = "karpenter-controller-policy"
  policy = templatefile("${path.module}/karpenter.json", {
    account_id  = data.aws_caller_identity.current.account_id,
    cluster_name = var.cluster_name,
    node_arn  =  aws_iam_role.karpenter_node.arn
  })
}


resource "aws_iam_role_policy_attachment" "admin_policy_karpenter_controller" {
  role      = aws_iam_role.karpenter_controller.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "ec2full_karpenter_Controller" {
  role      = aws_iam_role.karpenter_controller.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "karpenter_custom_policy_controller_attach" {
  role      = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_controller_policy.arn
}



#########################################################################
##################   Karepenter Node IAM Role       #####################
#########################################################################


resource "aws_iam_role" "karpenter_node" {
  name = "KarpenterNodeRole-${var.cluster_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "karpenter_node_profile" {
  name = "karpenter-iam-profile"
  role = aws_iam_role.karpenter_node.name
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ec2_container_registry" {
  role      = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_eks_cni" {
  role      = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_eks_worker_node" {
  role      = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ssm" {
  role      = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}



#########################################################################
###############   EKS LoadBalancer Controller Role       ################
#########################################################################


resource "aws_iam_role" "loadbalancer_controller" {
  name = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRoleWithWebIdentity"]
        Effect = "Allow"
        Principal = {
          Federated = var.irsa_oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${local.irsa_oidc_provider_url}:sub" = [for sa in var.irsa_namespace_service_accounts_loadbalancer : "system:serviceaccount:${sa}"]
            "${local.irsa_oidc_provider_url}:aud" = ["sts.amazonaws.com"]
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "loadbalancer_controller_policy" {
  name = "aws-loadbalancer-controller-policy"
  policy = templatefile("${path.module}/loadbalancer.json",{})
}

resource "aws_iam_role_policy_attachment" "loadbalancer_custom_policy_controller_attach" {
  role      = aws_iam_role.loadbalancer_controller.name
  policy_arn = aws_iam_policy.loadbalancer_controller_policy.arn
}


#########################################################################
#####################   Cloud Controller  Role       ####################
#########################################################################

resource "aws_iam_role" "cloud_controller" {
  name = "cloud-controller-sa-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRoleWithWebIdentity"]
        Effect = "Allow"
        Principal = {
          Federated = var.irsa_oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${local.irsa_oidc_provider_url}:sub" = [for sa in var.irsa_namespace_service_accounts_cloud_controller : "system:serviceaccount:${sa}"]
            "${local.irsa_oidc_provider_url}:aud" = ["sts.amazonaws.com"]
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "cloud_controller_policy" {
  name = "cloud-controller-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "*"
        Effect = "Allow"
        Resource = [
            "arn:aws:secretsmanager:ap-south-1:xxxxxxxxxxxx:secret:rds!db-26a0a755-482b-45c0-a476-973a73304501-2LW5eP",
            "arn:aws:secretsmanager:ap-south-1:xxxxxxxxxxxx:secret:rds!db-40eac872-158f-4575-b919-d120715982a1-Q0E6wo",
            "arn:aws:secretsmanager:ap-south-1:xxxxxxxxxxxx:secret:cmss/wf_prd_meta-xxxxxxx",
            "arn:aws:secretsmanager:ap-south-1:xxxxxxxxxxxx:secret:cmss/wf_prd_controller-xxxxxx",
            "arn:aws:secretsmanager:ap-south-1:xxxxxxxxxxxx:secret:cmss/wf_prd_te-xxxxxx",
            "arn:aws:secretsmanager:ap-south-1:xxxxxxxxxxxx:secret:cmss/wf_prd_uaa-xxxxxx",
            "arn:aws:secretsmanager:ap-south-1:xxxxxxxxxxxx:secret:cmss/wf_prd_location-xxxxxxx"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "RDS_policy_cloud_controller" {
  role      = aws_iam_role.cloud_controller.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "cloud_custom_policy_controller_attach" {
  role      = aws_iam_role.cloud_controller.name
  policy_arn = aws_iam_policy.cloud_controller_policy.arn
}

#########################################################################
##############   S3 Loki log service account Role       #################
#########################################################################

resource "aws_iam_role" "s3_loki_role" {
  name = "s3_logs_loki_service_account_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRoleWithWebIdentity"]
        Effect = "Allow"
        Principal = {
          Federated = var.irsa_oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${local.irsa_oidc_provider_url}:sub" = [for sa in var.irsa_namespace_service_accounts_s3_loki_role : "system:serviceaccount:${sa}"]
            "${local.irsa_oidc_provider_url}:aud" = ["sts.amazonaws.com"]
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "loki_s3full_policy" {
  role      = aws_iam_role.s3_loki_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


#########################################################################
#################  Amazon EKS EBS CSI Driver Role       #################
#########################################################################

resource "aws_iam_role" "eks_ebs_csi_driver" {
  name = "AmazonEKS_EBS_CSI_DriverRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRoleWithWebIdentity"]
        Effect = "Allow"
        Principal = {
          Federated = var.irsa_oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${local.irsa_oidc_provider_url}:sub" = [for sa in var.irsa_namespace_service_accounts_ebs_csi : "system:serviceaccount:${sa}"]
            "${local.irsa_oidc_provider_url}:aud" = ["sts.amazonaws.com"]
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_ebs_csi_policy" {
  role      = aws_iam_role.eks_ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
