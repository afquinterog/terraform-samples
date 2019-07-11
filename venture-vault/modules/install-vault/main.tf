
provider "aws" {
  region = var.aws_region
}

#Ubuntu AMI reference
data "aws_ami" "ubuntu" {
  most_recent = "true"
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#Template to install vault
# data "template_file" "vault" {
#   template = file("install-vault.tpl")

#   vars = {
#     version = var.vault_version
#   }
# }


resource "random_pet" "env" {
  length    = 2
  separator = "_"
}

resource "aws_security_group" "vault" {
  name = "vault-kms-unseal-${random_pet.env.id}"
  description = "vault access"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "vault-kms-unseal-${random_pet.env.id}"
  }

  # SSH
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Vault Client Traffic
  ingress {
    from_port = 8200
    to_port = 8200
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "vault-kms-unseal-${random_pet.env.id}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

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

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "vault-kms-unseal-${random_pet.env.id}"
  }
}

resource "aws_route_table_association" "route" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route.id
}


#Create the instance
resource "aws_instance" "vault" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  count         = 1
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = "vault-kms-unseal-${random_pet.env.id}"

  security_groups = [
    aws_security_group.vault.id,
  ]

  associate_public_ip_address = true
  ebs_optimized               = false
  #iam_instance_profile        = aws_iam_instance_profile.vault-kms-unseal.id
  #
  connection {
    type     = "ssh"
    user     = "ubuntu"
    password = ""
    host = self.public_ip
    #private_key = "${file("~/.ssh/id_rsa")}"
    private_key = tls_private_key.main.private_key_pem
  }

  #user_data = data.template_file.vault.rendered

  provisioner "file" {
    source      = "install-vault.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh --version ${var.vault_version}",
    ]
  }

  tags = {
    Name = "vault-instance-${random_pet.env.id}"
  }
}

data "template_file" "vault" {
  template = file("run-vault.tpl")

  vars = {
    dynamo_table = var.dynamodb_table
    #kms_key    = aws_kms_key.vault.id
    #vault_url  = var.vault_url
    #aws_region = var.aws_region
  }
}




#ssk key
resource "tls_private_key" "main" {
  algorithm = "RSA"
}

resource "null_resource" "main" {
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.main.private_key_pem}\" > private.key"
  }

  provisioner "local-exec" {
    command = "chmod 600 private.key"
  }
}

resource "aws_key_pair" "main" {
  key_name   = "vault-kms-unseal-${random_pet.env.id}"
  public_key = tls_private_key.main.public_key_openssh
}


