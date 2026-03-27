# =============================================================================
# VPC
# =============================================================================
resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = "10.190.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "jenkins-vpc"
    environment = "dev"
    owner       = "thedawgs"
  }
}