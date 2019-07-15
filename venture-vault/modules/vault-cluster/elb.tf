resource "aws_security_group" "elb" {
  name = "vault-venture-elb-${random_pet.env.id}"
  description = "Vault venture ELB"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "vault-venture-elb-${random_pet.env.id}"
  }

  # HTTP
  ingress {
    from_port = 80
    to_port = 80
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

resource "aws_lb" "venture" {
  name               = "vault-venture-${random_pet.env.id}"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.elb.id,
  ]

  subnets = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id,
  ]

  enable_deletion_protection = true

  tags = {
    Environment = "vault-venture-${random_pet.env.id}"
  }
}

resource "aws_lb_target_group" "venture" {
  name     = "vault-venture-${random_pet.env.id}"
  port     = 8200
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "venture-vault-1" {
  target_group_arn = aws_lb_target_group.venture.arn
  target_id        = aws_instance.vault[0].id
  port             = 8200
}

resource "aws_lb_target_group_attachment" "venture-vault-2" {
  target_group_arn = aws_lb_target_group.venture.arn
  target_id        = aws_instance.vault2[0].id
  port             = 8200
}

resource "aws_lb_listener" "vault" {
  load_balancer_arn = aws_lb.venture.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.venture.arn
  }
}


