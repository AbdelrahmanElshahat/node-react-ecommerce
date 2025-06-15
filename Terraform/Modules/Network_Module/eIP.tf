#Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  vpc = true
}