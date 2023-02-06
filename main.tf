provider "aws" {
    region ="ap-south-1"
    
}

variable "subnet_cidr_block"{
    description = "Subnet cidr block"
}

variable "vpc_cidr_block"{
    description = "VPC cidr block"
}

variable "env_prefix"{
    description = "Evnivornemt"
}

variable "my_ip"{
    description = "My ip address"
}

variable "instance_type"{
}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
       
    }
}

resource "aws_subnet" "myapp-subnet-1"{
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = "ap-south-1a"
    tags = {
        Name = "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id

  tags = {
    Name = "${var.env_prefix}-igw"
  }
}


resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-rtb"
  }
}

resource "aws_route_table_association" "a-rtb-subnet"{
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-route-table.id
}


resource "aws_security_group" "myapp-sg" {
  name        = "myapp-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.myapp-vpc.id

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

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = "ap-south-1a"

    associate_public_ip_address = true
    key_name = "server-key-pairs" 
    tags = {
    Name = "${var.env_prefix}-server"
  }
}

data "aws_ami" "latest-amazon-linux-image"{
    most_recent = true
    owners = ["137112412989"]

    filter{
        name ="name"
        values = ["amzn2-ami-kernel-5.*"]
    }

    filter{
        name ="virtualization-type"
        values = ["hvm"]
    }

}

# output "ami-id"{

#     value = data.aws_ami.latest-amazon-linux-image
# }

# data "aws_vpc" "existing_vpc" {
#     default = true
# }

# resource "aws_subnet" "dev-subnet-2"{
#     vpc_id = data.aws_vpc.existing_vpc.id
#     cidr_block = var.subnet_cidr_block
#     availability_zone = "ap-south-1a"
#     tags = {
#         Name = "subnet-1-Default"
#     }
# }

# output "dev-vpc-id" {
#     value = aws_vpc.devlopment-vpc.id
    
# }



