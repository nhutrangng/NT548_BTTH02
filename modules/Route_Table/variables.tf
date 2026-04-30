variable "vpc_id" {
  type = string

}
variable "igw" {
  type = string
}
variable "subnet_public_id" {
  type = list(string)
}
variable "nat_id" {
  type = string
}
variable "subnet_private_id" {
  type = list(string)
}