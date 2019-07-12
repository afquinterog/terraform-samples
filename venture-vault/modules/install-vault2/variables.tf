variable "aws_region" {
  default = "us-east-1"
}

variable "aws_zone" {
  default = "us-east-1a"
}

variable "vault_url" {
  default = "https://releases.hashicorp.com/vault/1.1.3/vault_1.1.3_linux_amd64.zip"
}

variable "dynamodb_uri" {
}

variable "dynamodb_table" {
}


variable "vpc_cidr" {
  type        = string
  description = "CIDR of the VPC"
  default     = "192.168.100.0/24"
}
