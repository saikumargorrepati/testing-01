# main.tf

provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "sai_vpc" {
  cidr_block = "120.0.0.0/16"

  tags = {
    Name = "sai-vpc"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "sai_igw" {
  vpc_id = aws_vpc.sai_vpc.id

  tags = {
    Name = "sai-igw"
  }
}

# Create a Subnet
resource "aws_subnet" "sai_subnet" {
  vpc_id            = aws_vpc.sai_vpc.id
  cidr_block        = "120.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "sai-subnet"
  }
}

# Create a Route Table
resource "aws_route_table" "sai_route_table" {
  vpc_id = aws_vpc.sai_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sai_igw.id
  }

  tags = {
    Name = "sai-route-table"
  }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "sai_route_table_assoc" {
  subnet_id      = aws_subnet.sai_subnet.id
  route_table_id = aws_route_table.sai_route_table.id
}

# Create a Security Group
resource "aws_security_group" "sai_allow_ssh" {
  name        = "sai_allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.sai_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sai-allow-ssh"
  }
}

# Create an EC2 Instance
resource "aws_instance" "sai_instance" {
  ami                    = "ami-ami-08a0d1e16fc3f61ea" # Replace with a valid AMI ID
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.sai_deployer.key_name
  subnet_id              = aws_subnet.sai_subnet.id
  vpc_security_group_ids = [aws_security_group.sai_allow_ssh.id]

  tags = {
    Name = "sai-instance"
  }
}
