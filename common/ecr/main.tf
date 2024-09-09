resource "aws_ecr_repository" "repository" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.repository_name
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.use_cmk ? aws_kms_key.repository_key[0].arn : null
  }
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "repository_key" {
  count = var.use_cmk ? 1 : 0
  description = "Key used for encrypting repository ${var.repository_name}"
  deletion_window_in_days = 0
  enable_key_rotation = true
  tags = {
    Name = "${var.repository_name}-key"
  }
  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Id": "key-default-1",
      "Statement": [
        {
          "Sid": "Enable IAM User Permissions",
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          },
          "Action": "kms:*",
          "Resource": "*"
        }
      ]
    }
  EOF
}