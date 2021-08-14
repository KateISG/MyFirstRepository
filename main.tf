terraform {
  required_providers {
    #docker = {
    #source  = "kreuzwerker/docker"
    #     version = "2.14.0"
    #}
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.13"
}

provider "aws" {
  region = var.region
}

#VPC 

resource "aws_vpc" "this" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    name = "My_vpc"
  }
}


#Private subnets

resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "172.16.4.0/24"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "Private1"
  }

}

resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "172.16.2.0/24"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "Private2"
  }
}

resource "aws_subnet" "private3" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "172.16.3.0/24"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "Private3"
  }
}

#Public subnets
resource "aws_subnet" "public1" {

  vpc_id            = aws_vpc.this.id
  cidr_block        = "172.16.5.0/24"
  availability_zone = "us-east-1c"
  tags = {
    name = "Public1"
  }
}
resource "aws_subnet" "public2" {

  vpc_id                  = aws_vpc.this.id
  cidr_block              = "172.16.22.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    name = "Public2"
  }
}
resource "aws_subnet" "public3" {

  vpc_id                  = aws_vpc.this.id
  cidr_block              = "172.16.15.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    name = "Public3"
  }
}
resource "aws_internet_gateway" "GateVPC" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "Gate1"
  }
}

resource "aws_route_table" "Public_route" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.GateVPC.id
  }
  tags = {
    Name = "Public_route"
  }
}

#security group

resource "aws_security_group" "ssh-input" {
  vpc_id = aws_vpc.this.id
  name   = "ssh-input"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ssh-input"
  }
}

#key pair 

resource "tls_private_key" "Key1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "keyec2" {
  key_name   = "FirstKey"
  public_key = tls_private_key.Key1.public_key_openssh
}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

#resource "aws_network_interface" "Lab1_netw" {
#  subnet_id   = aws_subnet.private1.id
#  private_ips = ["172.16.4.100"]

#  tags = {
#    Name = "network_interface"
#  }
#}
#EC2 public 

resource "aws_instance" "test" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.keyec2.key_name
 # network_interface {
 #   network_interface_id = aws_network_interface.Lab1_netw.id
 #   device_index         = 0
 # }
  tags = {
    Name = "Open-ec2"
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
}
