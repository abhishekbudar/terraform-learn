provider "aws" {
    # region ="ap-south-1"
    # access_key = "AKIATPZGSZFU4X2WOQNX"
    # secret_key = "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"
}

variable "subnet_cidr_block"{
    description = "Subnet cidr block"
}

variable "vpc_cidr_block"{
    description = "VPC cidr block"
}

resource "aws_vpc" "devlopment-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "Devlopment"
        vpc_env = "Dev"
    }
}

resource "aws_subnet" "dev-subnet-1"{
    vpc_id = aws_vpc.devlopment-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = "ap-south-1a"
    tags = {
        Name = "subnet-1-Dev"
    }
}

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



