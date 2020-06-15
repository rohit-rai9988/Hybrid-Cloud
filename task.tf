provider "aws" {
  region     = "ap-south-1"
  profile    = "cloud"
}

resource "aws_s3_bucket" "rohittttttt" {
  bucket = "rohittttttt" 
  acl    = "public-read"
  tags = {
    Name        = "rohittttttt" 
  }
  versioning {
	enabled =true
  }
}

resource "aws_s3_bucket_object" "s3object" {
  bucket = "${aws_s3_bucket.rohittttttt.id}"
  key    = "terraform.png"
  source = "C:/Users/rohit.rai/Downloads/terraform.png"
}
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "This is origin access identity"
}

resource "aws_cloudfront_distribution" "imagecf" {
    origin {
        domain_name = "rohittttttt.s3.amazonaws.com"
        origin_id = "S3-rohittttttt"


        s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
       
    enabled = true
      is_ipv6_enabled     = true

    default_cache_behavior {
        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = "S3-rohittttttt"


        # Forward all query strings, cookies and headers
        forwarded_values {
            query_string = false
        
            cookies {
               forward = "none"
            }
        }
        viewer_protocol_policy = "allow-all"
        min_ttl = 0
        default_ttl = 10
        max_ttl = 30
    }
    # Restricts who is able to access this content
    restrictions {
        geo_restriction {
            # type of restriction, blacklist, whitelist or none
            restriction_type = "none"
        }
    }


    # SSL certificate for the service.
    viewer_certificate {
        cloudfront_default_certificate = true
    }
}


resource "aws_security_group" "mysg" {
  name        = "mysg"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-6f9c8107"

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
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
    Name = "mysg"
  }
}


resource "aws_instance" "server" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  security_groups = ["mysg"]
  key_name = "cloud"

 connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/rohit.rai/Downloads/cloud.pem")
    host     = aws_instance.server.public_ip
  }
 
 provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }
   tags = {
    Name = "myserver"
  }
  }
  
  resource "aws_ebs_volume" "myebs" {
  availability_zone = aws_instance.server.availability_zone
  size              = 1

  tags = {
    Name = "myebs"
  }
}
  
resource "aws_volume_attachment" "ebs_attach" {
  depends_on = [aws_ebs_volume.myebs,aws_instance.server]
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.myebs.id
  instance_id = aws_instance.server.id
  force_detach =true
}  
  
  resource "null_resource" "null_remote" {
  depends_on = [aws_volume_attachment.ebs_attach]
  
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/rohit.rai/Downloads/cloud.pem")
    host     = aws_instance.server.public_ip
  }
   provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdh",
      "sudo mount /dev/xvdh /var/www/html",
      "sudo rm -rf /var/www/html/*",
	  "sudo git clone  https://github.com/rohit-rai9988/Hybrid-Cloud.git /var/www/html/"
       	   
    ]
  }
  }
  
  
