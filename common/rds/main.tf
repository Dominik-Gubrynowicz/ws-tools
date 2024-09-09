# Create rds instance
data "aws_kms_alias" "rds_default" {
  name = "alias/aws/rds"
}

resource "aws_rds_cluster" "cluster" {
  cluster_identifier      = var.instance_name
  engine                  = "aurora-postgresql" # aurora-mysql
  database_name           = var.default_database_name
  master_username         = var.username
  master_password         = var.password
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"

  storage_encrypted = true
  kms_key_id        = var.use_cmk ? aws_kms_key.database_key : data.aws_kms_alias.rds_default.target_key_arn

  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [
    aws_security_group.rds_group.id
  ]
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 3
  identifier         = "${var.instance_name}-${count.index}"
  cluster_identifier = aws_rds_cluster.cluster.id
  instance_class     = var.instance_type
  engine             = aws_rds_cluster.cluster.engine
  engine_version     = aws_rds_cluster.cluster.engine_version
}


resource "aws_db_subnet_group" "subnet_group" {
  name       = var.instance_name
  subnet_ids = var.subnet_ids

  tags = {
    Name = var.instance_name
  }
}

resource "aws_security_group" "rds_group" {
  name        = "${var.instance_name}-rds-sg"
  description = "Allow access to RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}