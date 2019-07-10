
provider "aws" {
  region = var.aws_region
}

#Ubuntu AMI reference
data "aws_ami" "ubuntu" {
  most_recent = "true"
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-18.04-amd64-server-*"]
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
  iam_instance_profile        = aws_iam_instance_profile.vault-kms-unseal.id

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

  #user_data = data.template_file.vault.rendered
}


