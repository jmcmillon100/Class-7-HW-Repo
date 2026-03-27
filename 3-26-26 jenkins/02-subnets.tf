# =============================================================================
# Subnets
# =============================================================================
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = "10.190.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "jenkins-public-subnet"
    environment = "dev"
    owner       = "thedawgs"

  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.jenkins_vpc.id
  cidr_block        = "10.190.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name        = "jenkins-private-subnet"
    environment = "dev"
    owner       = "thedawgs"
  }
}

