
resource "aws_security_group" "vault" {
  name = "vault-venture-${random_pet.env.id}"
  description = "vault access"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "vault-venture-${random_pet.env.id}"
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

resource "aws_instance" "vault" {
  ami           = var.vault_ami
  instance_type = "t2.micro"
  count         = 1
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = "vault-venture-${random_pet.env.id}"

  security_groups = [
    aws_security_group.vault.id,
  ]

  associate_public_ip_address = true
  ebs_optimized               = false
  iam_instance_profile        = aws_iam_instance_profile.vault-venture.id

  tags = {
    Name = "vault-venture-${random_pet.env.id}"
  }

  #user_data = data.template_file.vault.rendered
}

resource "aws_instance" "vault2" {
  ami           = var.vault_ami
  instance_type = "t2.micro"
  count         = 1
  subnet_id     = aws_subnet.subnet2.id
  key_name      = "vault-venture-${random_pet.env.id}"

  security_groups = [
    aws_security_group.vault.id,
  ]

  associate_public_ip_address = true
  ebs_optimized               = false
  iam_instance_profile        = aws_iam_instance_profile.vault-venture.id

  tags = {
    Name = "vault-venture-${random_pet.env.id}"
  }

  #user_data = data.template_file.vault.rendered
}

output "connections" {
  value = <<VAULT
Connect to Vault via SSH   ssh ubuntu@${aws_instance.vault[0].public_ip} -i private.key
Connect to Vault via SSH   ssh ubuntu@${aws_instance.vault[1].public_ip} -i private.key
Vault web interface  http://${aws_instance.vault[0].public_ip}:8200/ui
VAULT
}



