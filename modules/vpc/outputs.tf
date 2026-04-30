output "vpc_id" {
  value = aws_vpc.lab1.id
}

output "public_subnet_ids" {
  value = [for k, v in aws_subnet.this : v.id if local.subnets[k].type == "public"]
}
output "private_subnet_ids" {
  value = [for k, v in aws_subnet.this : v.id if local.subnets[k].type == "private"]
}
output "igw" {
  value = aws_internet_gateway.IGW.id
}