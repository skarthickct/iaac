resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"
}


resource "aws_instance" "bastion_host" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_ids
  vpc_security_group_ids =  var.security_group_ids                          #  aws_security_group.bastion_host_sg.id                    
  key_name      = var.key_name
  iam_instance_profile = var.iam_profile                                    # attach bastion host iam role 
  associate_public_ip_address  =  true
  user_data = var.userdata

  root_block_device {

    delete_on_termination = var.delete_with_instance
    volume_type = var.volume_type
    volume_size = var.volume_size
    encrypted   = true
  }

  tags = {
    Name = var.instance_name
  }
}

