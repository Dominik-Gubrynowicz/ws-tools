# Fetch ECS optimized template
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-${var.ec2_arch}-ebs"]
  }
}

# Create a launch template for ec2 fleet for ECS
resource "aws_launch_template" "ec2_fleet_template" {
  name                   = var.app_name
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
  user_data              = base64encode(templatefile("userdata.yml", {
    ssh_public_key=file("${path.module}/../id_rsa.pub"),
    ecs_cluster=aws_ecs_cluster.ecs_cluster.name
  }))


  dynamic "iam_instance_profile" {
    for_each = var.ec2_role_name == null ? [] : [var.ec2_role_name]
    content {
      name = aws_iam_instance_profile.ec2_profile[0].name
    }
  }
  
  tags = {
    Name = var.app_name
    Service = "ws"
    Owner = "dominik"
  }
}

# EC2 security group
resource "aws_security_group" "ecs_sg" {
  name        = "${var.app_name}-ecs-sg"
  description = "Allow access to ecs tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self = true
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [ aws_security_group.alb_group.id ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-ecs-sg"
    Service = "ws"
    Owner = "dominik"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  count       = var.ec2_role_name == null ? 0 : 1
  name_prefix = "ec2_profile"
  role        = var.ec2_role_name
}

# Autoscaling group for ecs capacity provider
resource "aws_autoscaling_group" "ecs_asg" {
  name                = "${var.app_name}-asg"
  min_size            = 2
  max_size            = var.max_instance_number
  desired_capacity    = 2
  vpc_zone_identifier = var.app_subnet_ids

  launch_template {
    id      = aws_launch_template.ec2_fleet_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.app_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Service"
    value               = "ws"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = "dominik"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [ desired_capacity ]
  }
}

# Register ec2 instances to cluster
resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = var.app_name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 5
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 90
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ec2_cluster" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = [ aws_ecs_capacity_provider.ecs_capacity_provider.name ]
  default_capacity_provider_strategy {
    base = 1
    weight = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
  }
}