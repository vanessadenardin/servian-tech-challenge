resource "aws_rds_cluster" "postgres" {
  cluster_identifier      = "${var.prefix}-db"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  engine_version          = var.postgresql_version
  availability_zones      = data.aws_availability_zones.azs.names
  master_username         = "postgres"
  master_password         = var.postgresql_password
  database_name           = "app"
  vpc_security_group_ids  = [aws_security_group.db.id]
  deletion_protection     = var.production ? true : false
  skip_final_snapshot     = var.production ? false : true
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  identifier          = "${var.prefix}-db-1"
  cluster_identifier  = aws_rds_cluster.postgres.id
  instance_class      = var.postgresql_instance_class
  engine              = aws_rds_cluster.postgres.engine
  engine_version      = aws_rds_cluster.postgres.engine_version
  # publicly_accessible = true
}

resource "aws_security_group" "db" {
  name        = "${var.prefix}-db"
  description = "Allow connections from server to db on port 5432"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description      = "port 5432 postgres"
      from_port        = 5432
      to_port          = 5432
      protocol         = "tcp"
      security_groups  = [aws_security_group.app.id]
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    }
  ]

  tags = {
    Name = "${var.prefix}-db"
  }
}
