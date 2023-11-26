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
resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.public_subnet1.id
    tags = {
        name = "NAT Gateway"
    }
}

# Create the public route table
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.production_vpc.id
    route {
        cidr_block = var.all_cidr
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "public RT"
    }
}

# Create the private route table
resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.production_vpc.id
    route {
        cidr_block = var.all_cidr
        nat_gateway_id = aws_nat_gateway.nat_gw.id
    }
    tags = {
        Name = "private RT"
    }
}

# Create the public submit 1
resource "aws_subnet" "public_subnet1" {
    vpc_id = aws_vpc.production_vpc.id
    cidr_block = var.public_subnet1_cidr
    availability_zone = var.availability_zone
    map_public_ip_on_launch = true
    tags = {
        Name = "Public subnet 1"
    }
}

# Create the public submit 2
resource "aws_subnet" "public_subnet2" {
    vpc_id = aws_vpc.production_vpc.id
    cidr_block = var.public_subnet2_cidr
    availability_zone = "eu-north-1b"
    map_public_ip_on_launch = true
    tags = {
        Name = "Public subnet 2"
    }
}

# Create the private submit
resource "aws_subnet" "private_subnet" { 
    vpc_id = aws_vpc.production_vpc.id
    cidr_block = var.private_subnet_cidr
    availability_zone = "eu-north-1b"
    tags = {
        Name = "Private subnet"
    }
}

# Associate publi RT with public subnet1
resource "aws_route_table_association" "public_association1" {
    subnet_id = aws_subnet.public_subnet1.id
    route_table_id = aws_route_table.public_rt.id
}

# Associate public RT with public subnet2
resource "aws_route_table_association" "public_association2" {
    subnet_id = aws_subnet.public_subnet2.id
    route_table_id = aws_route_table.public_rt.id
}

# Associate private RT with private subnet
resource "aws_route_table_association" "private_association" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_rt.id
}

# Create Jenkins security group
resource "aws_security_group" "jenkins_sg" {
    name = "Jenkins SG"
    description = "Allow ports 8080 and 22"
    vpc_id = aws_vpc.production_vpc.id

    ingress {
        description = "Jenkins"
        from_port = var.jenkins_port
        to_port = var.jenkins_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        description = "SSH"
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Jenkins SG"
    }
}

# Create Sonarqube security group
resource "aws_security_group" "sonarqube_sg" {
    name = "Sonarqube SG"
    description = "Allow ports 9000 and 22"
    vpc_id = aws_vpc.production_vpc.id

    ingress {
        description = "Sonarqube"
        from_port = var.sonarqube_port
        to_port = var.sonarqube_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        description = "SSH"
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Sonarqube SG"
    }
}

# Create Ansiblel security group
resource "aws_security_group" "ansible_sg" {
    name = "Ansible SG"
    description = "Allow ports 22"
    vpc_id = aws_vpc.production_vpc.id
    
    ingress {
        description = "SSH"
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Ansible SG"
    }
}

# Create Grafana security group
resource "aws_security_group" "grafana_sg" {
    name = "Grafana SG"
    description = "Allow ports 3000 and 22"
    vpc_id = aws_vpc.production_vpc.id

    ingress {
        description = "Grafana"
        from_port = var.grafana_port
        to_port = var.grafana_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        description = "SSH"
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Grafana SG"
    }
}

# Create Application security group
resource "aws_security_group" "app_sg" {
    name = "Application SG"
    description = "Allow ports 80 and 22"
    vpc_id = aws_vpc.production_vpc.id

    ingress {
        description = "Grafana"
        from_port = var.http_port
        to_port = var.http_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        description = "SSH"
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Application SG"
    }
}


# Create LoadBalancer security group
resource "aws_security_group" "lb_sg" {
    name = "LoadBalancer SG"
    description = "Allow ports 80"
    vpc_id = aws_vpc.production_vpc.id

    ingress {
        description = "LoadBalancer"
        from_port = var.http_port
        to_port = var.http_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "LoadBalancer SG"
    }
}

# Create the ACL
resource "aws_network_acl" "nacl" {
    vpc_id = aws_vpc.production_vpc.id
    subnet_ids = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id, aws_subnet.private_subnet.id]
    
    egress {
        protocol = "tcp"
        rule_no = "100"
        action = "allow"
        cidr_block = var.vpc_cidr
        from_port = 0
        to_port = 0
    }

    ingress {
        protocol = "tcp"
        rule_no = "100"
        action = "allow"
        cidr_block = var.all_cidr
        from_port = var.http_port
        to_port = var.http_port
    }

    ingress {
        protocol = "tcp"
        rule_no = "101"
        action = "allow"
        cidr_block = var.all_cidr
        from_port = var.ssh_port
        to_port = var.ssh_port
    }

    ingress {
        protocol = "tcp"
        rule_no = "102"
        action = "allow"
        cidr_block = var.all_cidr
        from_port = var.jenkins_port
        to_port = var.jenkins_port
    }

    ingress {
        protocol = "tcp"
        rule_no = "103"
        action = "allow"
        cidr_block = var.all_cidr
        from_port = var.sonarqube_port
        to_port = var.sonarqube_port
    }

    ingress {
        protocol = "tcp"
        rule_no = "104"
        action = "allow"
        cidr_block = var.all_cidr
        from_port = var.grafana_port
        to_port = var.grafana_port
    }

    tags = {
        Name = "Main ACL"
    }
}

# Create the ECR repository
resource "aws_ecr_repository" "ecr_repo" {
    name = "docker_repository"

    image_scanning_configuration {
        scan_on_push = true
    }
}

resource "aws_key_pair" "auth_key" {
    key_name = var.key_name
    public_key = var.key_value
}