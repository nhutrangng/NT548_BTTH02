resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
}
resource "aws_route" "public_internet" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = var.igw
}
resource "aws_route_table_association" "public" {
  count = 2
  subnet_id = var.subnet_public_id[count.index] 
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
}
resource "aws_route" "private_nat" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = var.nat_id
}
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = var.subnet_private_id[count.index]
  route_table_id = aws_route_table.private.id
}