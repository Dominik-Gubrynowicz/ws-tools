resource "aws_ecs_task_definition" "app_taskdef" {
    family = var.app_name
    container_definitions = <<DEFINITION
[
  {
    "name": "${var.app_name}",
    "image": "${var.image_url}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": 0
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${var.app_name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "${var.app_name}"
      }
    }
  }
]
DEFINITION
    network_mode = "bridge"
    cpu = var.app_cpu
    memory = var.app_memory
    execution_role_arn = "${var.execution_task_role}"
    task_role_arn = "${var.task_role}"
}