# =============================================================================
# Security Groups
# =============================================================================

# Bastion — accepts SSH from the internet, forwards into the private subnet
resource "aws_security_group" "bastion_sg" {
  name        = "jenkins-bastion-sg"
  description = "Bastion host - SSH inbound from internet"
  vpc_id      = aws_vpc.jenkins_vpc.id

  tags = {
    Name        = "jenkins-bastion-sg"
    environment = "dev"
    owner       = "thedawgs"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion_sg.id
  description       = "SSH - lock to your IP in production"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = { 
    Name = "bastion-ssh-22"
    environment = "dev"
    owner       = "thedawgs"
  }
}

resource "aws_vpc_security_group_egress_rule" "bastion_egress" {
  security_group_id = aws_security_group.bastion_sg.id
  description       = "Allow all outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = { 
    Name = "bastion-egress-all"
    environment = "dev"
    owner       = "thedawgs"
  }
}

# Jenkins — accepts SSH only from bastion, and port 8080 from within the VPC
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-server-sg"
  description = "Jenkins server - private subnet"
  vpc_id      = aws_vpc.jenkins_vpc.id

  tags = {
    Name        = "jenkins-server-sg"
    environment = "dev"
    owner       = "thedawgs"
  }
}

resource "aws_vpc_security_group_ingress_rule" "jenkins_ssh_from_bastion" {
  security_group_id            = aws_security_group.jenkins_sg.id
  description                  = "SSH from bastion only"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion_sg.id # SG reference, not CIDR

  tags = { 
    Name = "jenkins-ssh-from-bastion"
    environment = "dev"
    owner       = "thedawgs"
  }
}

resource "aws_vpc_security_group_ingress_rule" "jenkins_ui" {
  security_group_id = aws_security_group.jenkins_sg.id
  description       = "Jenkins UI - VPC internal only"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
  cidr_ipv4         = aws_vpc.jenkins_vpc.cidr_block

  tags = { 
    Name = "jenkins-ui-8080"
    environment = "dev"
    owner       = "thedawgs"
  }
}

resource "aws_vpc_security_group_egress_rule" "jenkins_egress" {
  security_group_id = aws_security_group.jenkins_sg.id
  description       = "Allow all outbound (via NAT GW)"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = { 
    Name = "jenkins-egress-all"
    environment = "dev"
    owner       = "thedawgs"
  }
}
