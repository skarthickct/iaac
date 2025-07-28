
output "bastion_host_sg" {
  value = resource.aws_security_group.bastion_host_sg.id
}

