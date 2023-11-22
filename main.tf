# Create the VPC
resource "aws_vpc" "production_vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "Production VPC"
    }
}
