resource "aws_ecs_cluster" "ecs_cluster" {
    name = "${var.app_name}-cluster"

    setting {
        name  = "containerInsights"
        value = "enabled"
    }
}

resource "aws_ecs_service" "service" {
    name = "${var.app_name}-service"
    cluster = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.app_taskdef.arn
    desired_count = 2

    enable_execute_command = true
    enable_ecs_managed_tags = true

    load_balancer {
        target_group_arn = aws_lb_target_group.alb_tg.arn
        container_name = var.app_name
        container_port = var.app_port
    }

    capacity_provider_strategy {
      base = 2
      capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
      weight = 100
    }
}

resource "aws_cloudwatch_log_group" "cw_logs" {
    name = "/ecs/${var.app_name}"
    retention_in_days = 7
}