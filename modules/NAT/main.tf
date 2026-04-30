resource "aws_eip" "ip_nat" {
  count = 2
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  count = 2
  allocation_id = aws_eip.ip_nat[count.index].id
  subnet_id = var.subnet_public_id[count.index]

  tags = {
    Name = "NAT-Lab 1"
  }
}

