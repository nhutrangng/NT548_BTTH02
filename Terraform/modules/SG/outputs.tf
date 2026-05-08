output "private_sg_id" {
  value = aws_security_group.sg-private-ec2.id
}
output "public_sg_id"{
  value = aws_security_group.sg-public-ec2.id
}