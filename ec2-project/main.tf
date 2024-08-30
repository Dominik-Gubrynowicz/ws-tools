# Create launch template
resource "aws_launch_template" "launch_template" {
  name_prefix            = "lt-${var.app_name}"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_group.id]
  user_data              = filebase64("${path.module}/userdata.sh")

  dynamic "iam_instance_profile" {
    for_each = var.role_name == null ? [] : [var.role_name]
    content {
      name = aws_iam_instance_profile.ec2_profile[0].name
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_iam_instance_profile" "ec2_profile" {
  count       = var.role_name == null ? 0 : 1
  name_prefix = "ec2_profile"
  role        = var.role_name
}
# Create autoscaling group
resource "aws_autoscaling_group" "asg" {
  name_prefix         = var.app_name
  vpc_zone_identifier = var.app_subnet_ids

  min_size         = 2
  max_size         = var.max_number
  desired_capacity = 2

  target_group_arns = [aws_lb_target_group.alb_tg.arn]

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}
# Target group
resource "aws_lb_target_group" "alb_tg" {
  name_prefix = "tg-${var.app_name}"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path     = var.health_check_path
    interval = 30
  }

  lifecycle {
    create_before_destroy = true
  }
}
# Create alb
resource "aws_lb" "alb" {
  name_prefix        = "alb-${var.app_name}"
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