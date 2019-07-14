data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "vault-venture" {
  statement {
    sid       = "VaultKMSUnseal"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
  }

  statement {
    sid       = "VaultDynamoDb"
    effect    = "Allow"
    resources = ["${var.dynamodb_uri}"]

    actions = [
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
      "dynamodb:DescribeReservedCapacityOfferings",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:ListTables",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:CreateTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:Scan",
      "dynamodb:DescribeTable"
    ]
  }
}

resource "aws_iam_role" "vault-venture" {
  name               = "vault-kms-role-${random_pet.env.id}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "vault-venture" {
  name   = "vault-venture-${random_pet.env.id}"
  role   = aws_iam_role.vault-venture.id
  policy = data.aws_iam_policy_document.vault-venture.json
}

resource "aws_iam_instance_profile" "vault-venture" {
  name = "vault-venture-${random_pet.env.id}"
  role = aws_iam_role.vault-venture.name
}
