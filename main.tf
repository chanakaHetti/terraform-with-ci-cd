/*
We defined this sensitive data using
$env code inside the local 
terminal


# Initiate the provide
provider "aws" {
    region = region
    access_key = access_key
    secret_key = secret_key
}
*/

# Create the VPC
resource "aws_vpc" "production_vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "Production VPC"
    }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.production_vpc.id
}

# Creating an elastic IP to associate with API gateway
resource "aws_eip" "nat_eip" {
    depends_on = [ aws_internet_gateway.igw ]
}

# Create the NAT Gateway
# resource "aws_nat_gateway" "nat_gw" {
#     allocation_id = aws_eip.nat_eip.id
#     subnet_id = aws_subnet.public_subnet1.id
#     tags = {
#         name = "NAT Gateway"
#     }
# }