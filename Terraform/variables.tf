variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "my_ip" {
  description = "Your public IP address (CIDR format) allowed to SSH into public EC2"
  type        = list(string)
}
