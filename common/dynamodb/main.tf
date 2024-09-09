resource "aws_dynamodb_table" "dynamodb" {
  name         = var.dynamodb_name
  hash_key     = var.dynamodb_primary_key
  range_key    = var.dynamodb_sort_key
  billing_mode = "PAY_PER_REQUEST"

  server_side_encryption {
    enabled     = true
    kms_key_arn = null
  }

  attribute {
    name = var.dynamodb_primary_key
    type = "S"
  }
  dynamic "attribute" {
    for_each = var.dynamodb_sort_key != null ? [var.dynamodb_sort_key] : []
    content {
      name = attribute.value
      type = "S"
    }
  }
}

