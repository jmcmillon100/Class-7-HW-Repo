# =============================================================================
# Bastion Host — public subnet, jump box for SSH into Jenkins
# =============================================================================
resource "aws_instance" "bastion" {
  ami                         = "ami-02dfbd4ff395f2a1b"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  key_name                    = "jenkins-id-rsa"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
  }

  tags = {
    Name        = "jenkins-bastion"
    environment = "dev"
    owner       = "thedawgs"
  }
}

# =============================================================================
# Jenkins Server — private subnet, no public IP
# =============================================================================
resource "aws_instance" "jenkins" {
  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.private.id
  key_name      = "jenkins-id-rsa"

  associate_public_ip_address = false # private subnet — no direct internet exposure
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.jenkins_profile.name

  user_data = file("${path.module}/jenkins.sh")

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
  }

  tags = {
    Name        = "jenkins_server"
    environment = "dev"
    owner       = "thedawgs"
  }
}