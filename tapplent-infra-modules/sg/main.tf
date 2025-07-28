resource "aws_security_group" "bastion_host_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22  
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust to restrict access
  }

  ingress {
    from_port   = 3100  
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust to restrict access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-bastion-host-sg"
    Environment = var.environment
  }
}


