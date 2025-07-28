output "bastion_host" {
  value       = aws_instance.bastion_host.id
  description = "Id of the bastion host master instance"
}
