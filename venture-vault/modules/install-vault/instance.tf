
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

resource "aws_kms_key" "vault" {
  description             = "Vault unseal key"
  deletion_window_in_days = 10

  tags = {
    Name = "vault-kms-unseal-${random_pet.env.id}"
  }
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

  connection {
    type     = "ssh"
    user     = "ubuntu"
    password = ""
    host = self.public_ip
    private_key = tls_private_key.main.private_key_pem
  }

  user_data = data.template_file.vault.rendered

  provisioner "file" {
    source      = "install-vault.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "file" {
    source      = "run-vault.sh"
    destination = "/home/ubuntu/run-vault.sh"
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
    dynamodb_table = var.dynamodb_table
    kms_key    = aws_kms_key.vault.id
    aws_region = var.aws_region

    #kms_key    = aws_kms_key.vault.id
    #vault_url  = var.vault_url
    #aws_region = var.aws_region
  }
}
