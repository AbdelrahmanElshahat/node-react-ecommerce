#  NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.Public_Subnet1.id 



  tags = {
    Name = "nat-gateway"
  }
}