output "iam_role" {
  value = aws_iam_role.bastion_host_role.arn
}

output "instance_profile" {
  value = aws_iam_instance_profile.instance_profile.arn
}