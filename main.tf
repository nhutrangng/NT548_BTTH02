terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.cidr_block
}

module "nat" {
  source           = "./modules/NAT"
  subnet_public_id = module.vpc.public_subnet_ids
}

module "route_table" {
  source            = "./modules/Route_Table"
  vpc_id            = module.vpc.vpc_id
  igw               = module.vpc.igw
  subnet_public_id  = module.vpc.public_subnet_ids
  subnet_private_id = module.vpc.private_subnet_ids
  nat_id            = module.nat.nat_ids[0]
}

module "sg" {
  source        = "./modules/SG"
  vpc_id        = module.vpc.vpc_id
  my_ip         = var.my_ip
  public_subnet = ["10.0.3.0/24", "10.0.4.0/24"]
}

module "instance" {
  source            = "./modules/Instance"
  public_subnet_id  = module.vpc.public_subnet_ids
  private_subnet_id = module.vpc.private_subnet_ids
  public_sg_id      = module.sg.public_sg_id
  private_sg_id     = module.sg.private_sg_id
}
