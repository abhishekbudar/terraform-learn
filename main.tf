provider "aws" {
    region ="ap-south-1"
}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
       
    }
}

module "myapp-subnet"{
    source = "./modules/subnet"
    subnet_cidr_block = var.subnet_cidr_block
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.myapp-vpc.id
       
}


module "myapp-webserver"{
    source = "./modules/webserver"
    vpc_id = aws_vpc.myapp-vpc.id
    my_ip = var.my_ip
    instance_type = var.instance_type
    env_prefix = var.env_prefix
    image_name =var.image_name
    public_key_location = var.public_key_location
    subnet_id = module.myapp-subnet.subnet.id
   
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





