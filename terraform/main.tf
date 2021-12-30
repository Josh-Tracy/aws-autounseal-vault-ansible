provider "aws" {
  region = "us-east-1"
  default_tags {
   tags = {
     Environment = "Dev"
     Owner       = "Josh Tracy"
     Project     = "Vault"
   }
 }
}

# Create VPC
resource "aws_vpc" "dev-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "development"
  }
}

# Create subnet(s)
# Subnets have to be allowed to automatically map public IP addresses for worker nodes
resource "aws_subnet" "dev1-subnet" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev1-subnet"
  }
}


# Create Internet Gateway
resource "aws_internet_gateway" "dev-gw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "dev-gw"
  }
}

# Create Route Table
resource "aws_route_table" "dev-route-table" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.dev-gw.id
  }


  tags = {
    Name = "dev-rt"
  }
}

# Create Route Table Association for dev1-subnet to dev-rt
resource "aws_route_table_association" "dev1-sub-to-dev-rt" {
  subnet_id      = aws_subnet.dev1-subnet.id
  route_table_id = aws_route_table.dev-route-table.id
}


# Create a security group for HTTPS, HTTP, and SSH
resource "aws_security_group" "vault-server" {
  name        = "Vault"
  description = "Hashicorp Vault Ports"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Vault"
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "vault/ssh/http/https"
  }
}

# Create a NIC(s)
resource "aws_network_interface" "dev-server-nic" {
  subnet_id       = aws_subnet.dev1-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.vault-server.id]
}

# Create Elastic IP
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.dev-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.dev-gw]
}