resource "aws_subnet" "Private_Subnet1" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = var.Private_Subnet1_cidr
  availability_zone = var.Availabillity_Zone1
  
  tags = {
    Name = "Private Subnet"
  }
}
output "Private_Subnet1_id" {
  value = aws_subnet.Private_Subnet1.id
  
}
resource "aws_subnet" "Private_Subnet2" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = var.Private_Subnet2_cidr
  availability_zone = var.Availabillity_Zone2
 
  tags = {
    Name = "Private Subnet2"
  }
}

output "Private_Subnet2_id" {
  value = aws_subnet.Private_Subnet2.id
  
}