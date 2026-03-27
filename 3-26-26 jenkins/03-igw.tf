# =============================================================================
# Internet Gateway — gives the public subnet a path to the internet
# =============================================================================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = {
    Name        = "jenkins-igw"
    environment = "dev"
    owner       = "thedawgs"
  }
}