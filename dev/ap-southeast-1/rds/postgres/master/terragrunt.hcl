terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git//?ref=v4.4.0"
}

include {
  path   = find_in_parent_folders()
  expose = true
}

dependency "postgres_allow_internal_access_sg" {
  config_path = "../../../sg/postgres-allow-internal-access"
}

dependency "vpc" {
  config_path = "../../../vpc"
}

locals {
  name                  = "postgresql"
  engine                = "postgres"
  engine_version        = "14.2"
  family                = "postgres14.2" # DB parameter group
  major_engine_version  = "14.2"         # DB option group
  instance_class        = "db.t3.large"
  allocated_storage     = 20
  max_allocated_storage = 100
  port                  = 5432
}

inputs = {
  identifier = "${local.name}-master"

  engine               = local.engine
  engine_version       = local.engine_version
  family               = local.family
  major_engine_version = local.major_engine_version
  instance_class       = local.instance_class

  allocated_storage     = local.allocated_storage
  max_allocated_storage = local.max_allocated_storage
  storage_encrypted     = false

  name     = "postgresMaster"
  username = "postgres"
  password = "RandomStronkPassword"
  port     = local.port

  multi_az               = true
  create_db_subnet_group = false
  create_db_parameter_group = false
  db_subnet_group_name   = dependency.vpc.outputs.database_subnet_group_name
  subnet_ids             = dependency.vpc.outputs.database_subnets
  vpc_security_group_ids = ["${dependency.postgres_allow_internal_access_sg.outputs.security_group_id}"]

  maintenance_window              = "Sat:18:00-Sat:21:00"
  backup_window                   = "00:00-03:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # Backups are required in order to create a replica
  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false
}
