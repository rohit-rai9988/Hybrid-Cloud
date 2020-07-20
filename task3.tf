provider "aws" {
  region     = "ap-south-1"
  profile    = "cloud"
}

resource "aws_vpc" "task3" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Task3"
  }
}

resource "aws_subnet" "Public" {
  vpc_id     = aws_vpc.task3.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
 
  tags = {
    Name = "Public"
  }
}

resource "aws_subnet" "Private" {
  vpc_id     = aws_vpc.task3.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "Private"
  }
}

resource "aws_internet_gateway" "my_igv" {
  vpc_id = aws_vpc.task3.id
tags = {
    Name = "my_igv"
  }
}

resource "aws_route_table" "my_route" {
  vpc_id = aws_vpc.task3.id
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igv.id
  }
tags = {
    Name = "my_route"
  }
}

resource "aws_route_table_association" "PublicRT" {
  subnet_id      = aws_subnet.Public.id
  route_table_id = aws_route_table.my_route.id
}

resource "aws_security_group" "myFirewall" {
  name        = "mysg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.task3.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    description = "TLS from VPC"
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

ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "myFirewall"
  }
}
