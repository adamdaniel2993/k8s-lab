locals {
  rds_password_version = 1
}


ephemeral "random_password" "rds_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"

}

resource "aws_security_group" "postgres" {
  name        = "${var.project_name}-${var.environment}-postgres-sg"
  description = "Security group for PostgreSQL RDS"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres-sg"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_app_sg" {

  security_group_id            = aws_security_group.postgres.id
  referenced_security_group_id = [module.eks.cluster_security_group_id, module.eks.node_security_group_id]

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"

  description = "Allow PostgreSQL from app security group"
}


resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.postgres.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  description = "Allow all outbound traffic"
}

resource "aws_db_parameter_group" "postgres" {
  name        = "${var.project_name}-${var.environment}-postgres15-params"
  family      = "postgres15"
  description = "Parameter group for PostgreSQL 15"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres15-params"
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "postgres" {
  name       = "${var.project_name}-${var.environment}-postgres-subnet-group"
  subnet_ids = data.aws_subnets.private_subnets

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres-subnet-group"
    Environment = var.environment
  }
}

resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-${var.environment}-postgres"

  engine                     = "postgres"
  engine_version             = var.postgres_engine_version
  instance_class             = var.instance_class
  allocated_storage          = var.allocated_storage
  max_allocated_storage      = var.max_allocated_storage
  storage_type               = "gp3"
  storage_encrypted          = true
  db_name                    = var.db_name
  username                   = var.db_username
  password_wo                = ephemeral.random_password.rds_password.result
  password_wo_version        = local.rds_password_version
  port                       = 5432
  db_subnet_group_name       = aws_db_subnet_group.postgres.name
  vpc_security_group_ids     = [aws_security_group.postgres.id]
  parameter_group_name       = aws_db_parameter_group.postgres.name
  publicly_accessible        = false
  multi_az                   = false
  deletion_protection        = false
  skip_final_snapshot        = false
  auto_minor_version_upgrade = true
  apply_immediately          = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres"
    Environment = var.environment
  }
}