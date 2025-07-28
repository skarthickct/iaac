locals {
  environment_name = "Dev"
  project_name = "tapplent"
  region = "ap-south-1"
  vpc_id = "vpc-06a474b4ce759a73d"
  vpc_cidr = "172.31.0.0/16"

  karpenter_tag_key = "karpenter.sh/discovery"

  
  eks_controlplane_subnet_az1 = "subnet-05709e15dc4ba8637"
  eks_controlplane_subnet_az2 = "subnet-01f31edef0702ef61"


  #bastion host configuration
  bastion_host_name = "bastion-host-dev"
  key_name = "ap-south-1-key"                              # bastion host key pair

  instance_type                    = "t2.micro"
  public_access                    = true
  
  subnet_ids                      = "subnet-013e9aed439988287"
  #security_group_ids              = ["sg-0aa32f51af9d11c9c"]
  owner                            = "devops"
  ami_id                          = "ami-0f918f7e67a3323f0"
  volume_type                     = "gp3"
  volume_size                     = 20
  
  user_data                        =  <<-EOF
  #!/bin/bash
  sudo apt-get update -y
  sudo apt-get upgrade -y
  sudo apt-get install unzip -y
  cd
  sudo curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/amd64/kubectl
  sudo curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/amd64/kubectl.sha256
  openssl sha1 -sha256 kubectl
  sudo chmod +x ./kubectl
  sudo mkdir -p $HOME/bin && sudo cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
  sudo echo 'export PATH=$HOME/bin:$PATH' >> ~/.bash_profile
  sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  sudo chmod 700 get_helm.sh
  ./get_helm.sh
  sudo  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  EOF



  #    IAM ROLE for EC2 INSTANCE
  role_name             =  "bastion-dev"
  policy_name           =  "cluster-access-policy"
  profile_name          =  "iam-profile"
  }
