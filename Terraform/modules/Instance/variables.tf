variable "private_subnet_id" {
  type = list(string)
}
variable "public_subnet_id" {
  type = list(string)
}


variable "public_sg_id" {
  type = string
}
variable "private_sg_id" {
  type = string
}