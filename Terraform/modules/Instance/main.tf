data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "private-instance" {
  count = length(var.private_subnet_id)
  ami = data.aws_ami.ubuntu.id
  key_name = "NT548"
  instance_type = "t2.micro"
  subnet_id = var.private_subnet_id[count.index]
  vpc_security_group_ids = [var.private_sg_id]
  tags = {
    Name = "private-instance-${count.index}"
  }
}
resource "aws_instance" "public-instance" {
  count = length(var.public_subnet_id)
  ami = data.aws_ami.ubuntu.id
  key_name = "NT548"
  instance_type = "t2.micro"
  subnet_id = var.public_subnet_id[count.index]
  vpc_security_group_ids = [var.public_sg_id]
  associate_public_ip_address = true
  tags = {
    Name = "public-instance-${count.index}"
  }
}