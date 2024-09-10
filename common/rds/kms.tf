
data "aws_caller_identity" "current" {}
resource "aws_kms_key" "database_key" {
  count = var.use_cmk ? 1 : 0
  description = "Key used for encrypting repository ${var.instance_name}"
  deletion_window_in_days = 7
  enable_key_rotation = true
  tags = {
    Name = "${var.instance_name}-key"
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