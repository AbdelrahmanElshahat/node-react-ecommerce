# 8. Route Table for Private Subnets (via NAT)
resource "aws_route_table" "Private_Route_Table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Private_Route_Table"
  }
}

resource "aws_route_table_association" "private_1_assoc" {
  subnet_id      = aws_subnet.Private_Subnet1.id
  route_table_id = aws_route_table.Private_Route_Table.id
}

resource "aws_route_table_association" "private_2_assoc" {
  subnet_id      = aws_subnet.Private_Subnet2.id
  route_table_id = aws_route_table.Private_Route_Table.id
}