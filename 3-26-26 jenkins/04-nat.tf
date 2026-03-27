# =============================================================================
# NAT Gateway — gives the private subnet outbound-only internet access
# (plugin downloads, GitHub webhooks, package updates)
# =============================================================================
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "jenkins-nat-eip"
    environment = "dev"
    owner       = "thedawgs"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id # NAT GW must live in the public subnet

  tags = {
    Name        = "jenkins-nat-gw"
    environment = "dev"
    owner       = "thedawgs"
  }

  depends_on = [aws_internet_gateway.igw]
}
