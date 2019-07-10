variable "vault_version" {
  default = "1.1.3"
}

variable "aws_region" {
  default = "us-west-1"
}

variable "aws_zone" {
  default = "us-west-1a"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR of the VPC"
  default     = "10.0.0.0/16"
}
