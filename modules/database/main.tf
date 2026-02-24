locals {
  base_tags = {
    Environment = var.environment
    Creator     = var.prefname
    Purpose     = var.purpose
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.prefname}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-db-subnet-group"
  })
}

resource "aws_db_instance" "this" {
  identifier                 = "${var.prefname}-mysql-1"
  db_name                    = var.db_name
  username                   = var.db_username
  password                   = var.db_password
  engine                     = "mysql"
  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  max_allocated_storage      = 100
  storage_type               = "gp3"
  db_subnet_group_name       = aws_db_subnet_group.this.name
  vpc_security_group_ids     = [var.db_sg_id]
  publicly_accessible        = false
  parameter_group_name       = "default.mysql8.4"
  auto_minor_version_upgrade = false
  deletion_protection        = false
  storage_encrypted          = false
  skip_final_snapshot        = true

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-mysql-1"
  })
}
