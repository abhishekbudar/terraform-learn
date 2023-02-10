terraform {

    required_version = ">= 0.12"
    backend "s3" {
        bucket = "myapp-bucket"
        key = "myapp/state.tfstate"
    }
}

provider "aws" {
    region ="ap-south-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs             = ["ap-south-1a"]
  public_subnets  = [var.subnet_cidr_block]
  public_subnet_tags = {Name = "${var.env_prefix}-subnet-1" }
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

# resource "aws_vpc" "myapp-vpc" {
#     cidr_block = var.vpc_cidr_block
#     tags = {
#         Name = "${var.env_prefix}-vpc"
       
#     }
# }

# module "myapp-subnet"{
#     source = "./modules/subnet"
#     subnet_cidr_block = var.subnet_cidr_block
#     env_prefix = var.env_prefix
#     vpc_id = aws_vpc.myapp-vpc.id
       
# }


module "myapp-webserver"{
    source = "./modules/webserver"
    vpc_id = module.vpc.vpc_id
    my_ip = var.my_ip
    instance_type = var.instance_type
    env_prefix = var.env_prefix
    image_name =var.image_name
    public_key_location = var.public_key_location
    subnet_id = module.vpc.public_subnets[0]
   
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





