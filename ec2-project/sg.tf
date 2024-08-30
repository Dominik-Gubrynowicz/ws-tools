resource "aws_security_group" "ec2_group" {
  name        = "${var.app_name}-ec2-sg"
  description = "Allow app traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "-1"
    security_groups = [aws_security_group.alb_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Get cloudfront prefix list id
data "aws_ec2_managed_prefix_list" "cloudfront" {
  filter {
    name   = "prefix-list-name"
    values = ["com.amazonaws.global.cloudfront.origin-facing"]
  }
}

resource "aws_security_group" "alb_group" {
  name        = "${var.app_name}-alb-sg"
  description = "Allow app traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "-1"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}