resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = module.network.vpc_public_subnets

  tags = {
    Name = "Default subnet group"
  }
}

resource "aws_security_group" "sql_sg" {
  name        = "sql_sg"
  description = "SQL traffic"
  vpc_id      = module.network.vpc_id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [module.network.vpc_cidr]
    description = "Allow SQL"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "sg"
    Environment = var.environment
    Product     = var.product
  }
}

resource "aws_db_instance" "test_db" {
  allocated_storage           = 10
  db_name                     = "test_db"
  identifier                  = "testdb"
  engine                      = "mariadb"
  engine_version              = "10.6.14"
  instance_class              = "db.t2.micro"
  db_subnet_group_name        = aws_db_subnet_group.default.name
  manage_master_user_password = true
  username                    = "test"
  skip_final_snapshot         = true
  vpc_security_group_ids      = [aws_security_group.sql_sg.id]
}
