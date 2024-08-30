# Create alb
resource "aws_lb" "alb" {
  name_prefix        = var.app_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_group.id]
  subnets            = var.alb_subnet_ids

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.expose_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
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
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Target group
resource "aws_lb_target_group" "alb_tg" {
  name_prefix = var.app_name
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  deregistration_delay = 20

  health_check {
    path     = var.health_check_path
    interval = 30
  }

  lifecycle {
    create_before_destroy = true
  }
}
# resource "aws_lb_listener_rule" "app_rule" {
#     listener_arn = aws_lb_listener.alb_listener.arn
#     priority     = 100

#     action {
#         type = "forward"
#         target_group_arn = aws_lb_target_group.alb_tg.arn
#     }

#     condition {
#         path_pattern {
#             values = ["/*"]
#         }
#     }
# }