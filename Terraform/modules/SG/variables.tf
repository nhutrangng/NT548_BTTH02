variable "vpc_id" {
  type = string
}
variable "my_ip" {
  type = list(string)
}

variable "public_subnet" {
  type = list(string)
}