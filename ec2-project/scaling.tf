# Create target tracking scaling policy
resource "aws_autoscaling_policy" "autoscaling_policy" {
  name = "${var.app_name}_scaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label = "${aws_lb.alb.arn_suffix}/${aws_lb_target_group.alb_tg.arn_suffix}"
    }
    target_value = 50
  }
}