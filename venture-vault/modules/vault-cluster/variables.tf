variable "aws_region" {
  default = "us-west-1"
}

variable "aws_zone1" {
  default = "us-west-1a"
}

variable "aws_zone2" {
  default = "us-west-1c"
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


