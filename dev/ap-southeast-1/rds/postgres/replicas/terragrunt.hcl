terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git//?ref=v3.4.0"
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

dependency "master" {
  config_path = "../master"
}

locals {
  name                  = "postgresql"
  engine                = "postgres"
  engine_version        = "11.10"
  family                = "postgres11" # DB parameter group
  major_engine_version  = "11"         # DB option group
  instance_class        = "db.t3.large"
  allocated_storage     = 20
  max_allocated_storage = 100
  port                  = 5432
}

inputs = {
  identifier = "${local.name}-replica"

  # Source database. For cross-region use db_instance_arn
  replicate_source_db = dependency.master.outputs.db_instance_id

  engine               = local.engine
  engine_version       = local.engine_version
  family               = local.family
  major_engine_version = local.major_engine_version
  instance_class       = local.instance_class

  allocated_storage     = local.allocated_storage
  max_allocated_storage = local.max_allocated_storage
  storage_encrypted     = false

  # Username and password should not be set for replicas
  port = local.port

  multi_az               = false
  db_subnet_group_name   = dependency.vpc.outputs.database_subnet_group_name
  subnet_ids             = dependency.vpc.outputs.database_subnets
  vpc_security_group_ids = ["${dependency.postgres_allow_internal_access_sg.outputs.security_group_id}"]

  maintenance_window              = "Tue:00:00-Tue:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  # Not allowed to specify a subnet group for replicas in the same region
  create_db_subnet_group = false

  tags = {
    Terraform   = "true"
    Environment = include.inputs.env
    Owner       = include.inputs.account_name
  }
}
