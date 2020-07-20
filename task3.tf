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


resource "aws_instance" "task3" {
  ami           = "ami-0732b62d310b80e97"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.myFirewall.id]
  subnet_id = aws_subnet.Public.id
  key_name = "cloud"

connection {
 type      = "ssh"
 user      = "ec2-user"
 private_key = file("C:/Users/rohit.rai/Downloads/cloud.pem")
 host = aws_instance.task3.public_ip
  }

provisioner "remote-exec" {
 inline = [
    
        "sudo yum -y update",
        "sudo yum -y install httpd",
        "sudo systemctl enable httpd.service",
	"sudo systemctl start httpd.service",
	"sudo yum install wget -y",
	"sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
	"sudo yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm",
	"sudo yum-config-manager --disable remi-php54",
	"sudo yum-config-manager --enable remi-php56",
	"sudo yum install -y php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo",
	"sudo systemctl restart httpd.service",
	"sudo wget https://wordpress.org/latest.tar.gz",
	"sudo tar -xvf latest.tar.gz",
	"sudo rm -rf latest.tar.gz",
	"sudo rm -rf /var/www/html/*",
	"sudo mv wordpress/* /var/www/html/",
	"sudo rm -rf wordpress",
	"sudo chown -R apache:apache /var/www/html/",
	"sudo chcon -t httpd_sys_rw_content_t /var/www/html/ -R",
	"sudo sed -i s/^SELINUX=.*$/SELINUX=permissive/ /etc/selinux/config",
	"sudo setenforce 0",
	"sudo systemctl restart httpd.service",
  ]
 }

tags = {
 Name = "task3"
  }

}


