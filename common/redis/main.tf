resource "aws_elasticache_cluster" "redis" {
  cluster_id           = var.cluster_name
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  apply_immediately    = true
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  subnet_group_name    = aws_elasticache_subnet_group.subnet_group.name
  security_group_ids   = [aws_security_group.redis_group.id]
  engine_version       = "7.1"
  port                 = 6379
}

resource "aws_elasticache_subnet_group" "subnet_group" {
  name       = var.cluster_name
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "redis_group" {
  name_prefix = "redis-sg-${var.cluster_name}"
  description = "Security group for Redis cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}