variable "aws_region" {
  default = "us-east-2"
}

variable "aws_zone1" {
  default = "us-east-2a"
}

variable "aws_zone2" {
  default = "us-east-2b"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR of the VPC"
  default     = "10.0.0.0/16"
}

variable "dynamodb_uri" {
}

variable vault_ami {
}


