
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "vault-kms-unseal-${random_pet.env.id}"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc_cidr
  availability_zone       = var.aws_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "vault-kms-unseal-${random_pet.env.id}"
  }
}
