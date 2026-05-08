
############# VPC ################
resource "aws_vpc" "lab1" {
  cidr_block = var.cidr_block


  tags = {
    Name = "VPC-Lab 1"
  }
}
############  IQW ##############
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.lab1.id

  tags = {
    Name = "IGW-Lab 1"
  }
}
############ Subnet ##############
locals{
  azs = [
    "ap-southeast-1a",
    "ap-southeast-1b"
  ]
}
locals{
  subnets = {
    subnet-private-1 = {
      cidr_block = "10.0.1.0/24"
      az = local.azs[0]
      type = "private"
    },
    subnet-private-2 = {
      cidr_block = "10.0.2.0/24"
      az = local.azs[1]
      type = "private"
    }
    subnet-public-1 = {
      cidr_block = "10.0.3.0/24"
      az= local.azs[0]
      type = "public"
    },
    subnet-public-2 = {
      cidr_block = "10.0.4.0/24"
      az = local.azs[1]
      type = "public"
    }
  }
}
resource "aws_subnet" "this" {
  for_each = local.subnets
  vpc_id = aws_vpc.lab1.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.az
  map_public_ip_on_launch = each.value.type == "public" ? true : false

  tags = {
    Name : "${each.key}-Lab 1"
  }
}

