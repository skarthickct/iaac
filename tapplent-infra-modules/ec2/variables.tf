variable "instance_name" {
  description = "Name of the instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for server"
  type        = string
  # default     = "t2.medium"
}

variable "subnet_ids" {
  description = "Subnet ID"
  type        = string
  # default     = "subnet-0461fd3764a4a82ed"  # Replace with your actual subnet ID
}


variable "security_group_ids" {
  description = "Security Group IDs for servers"
  type        = list(string)
  # default     = ["sg-02d2d97d3efd0435f"]  # Replace with your security group ID
}

variable "ami_id" {
  description = "AMI ID for  server"
  type        = string
  # default     = "ami-0dee22c13ea7a9a67"  # Replace with your AMI ID
}

variable "key_name" {
  description = "key name for server"
  type        = string
  # default     = "production-key"  # Replace with your key name
}

variable "userdata" {
  description = "userdata for server"
  type        = string
}


variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}


variable "volume_type" {
  description = "EBS volume type"
  type        = string
}
 variable "volume_size" {
  description = "EBS volume size"
  type        = number
}

variable "delete_with_instance" {              
  type        = bool
  description = "Whether to enable delete volume along with instance or not"
}

variable "iam_profile" {              
  type        = string
  description = "Iam role for EC2 Instance"
}