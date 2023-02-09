
resource "aws_security_group" "myapp-sg" {
  name        = "myapp-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
    //ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  ingress {
    description      = "Inbound from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    //ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
   
  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

resource "aws_key_pair" "ssh-key"{

    key_name = "server-key"
    public_key = "${var.public_key_location}"
}



resource "aws_instance" "myapp-server1" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type
    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = "ap-south-1a"

    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

    user_data = <<EOF
                    #!/bin/bash
                    sudo yum update -y
                    sudo yum install -y docker
                    sudo systemctl start docker
                    sudo usermod -aG docker ec2-user
                    docker run -p 8080:80 nginx
                EOF

    tags = {
    Name = "${var.env_prefix}-server"
  }
}

data "aws_ami" "latest-amazon-linux-image"{
    most_recent = true
    owners = ["137112412989"]

    filter{
        name ="name"
        values = [var.image_name]
    }

    filter{
        name ="virtualization-type"
        values = ["hvm"]
    }
}