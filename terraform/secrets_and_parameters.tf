resource "aws_secretsmanager_secret" "postgres_credentials" {
  name                    = "/${var.project_name}/${var.environment}/rds/postgres/master"
  description             = "Master credentials for PostgreSQL RDS"
  recovery_window_in_days = 7

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres-secret"
    Environment = var.environment
  }
}


resource "aws_secretsmanager_secret_version" "postgres_credentials" {
  secret_id = aws_secretsmanager_secret.postgres_credentials.id

  secret_string_wo = jsonencode({
    username             = var.db_username
    password             = ephemeral.random_password.rds_password.result
    engine               = "postgres"
    host                 = aws_db_instance.postgres.address
    port                 = aws_db_instance.postgres.port
    dbname               = var.db_name
    dbInstanceIdentifier = aws_db_instance.postgres.identifier
  })
  secret_string_wo_version = local.rds_password_version

}