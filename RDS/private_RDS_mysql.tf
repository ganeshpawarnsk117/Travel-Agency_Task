# Creating private security group for MySQL, this will allow access only from the instances having the security group created above.
resource "aws_security_group" "PRV-SG" {

  /*depends_on = [
    aws_vpc.custom,
    aws_subnet.subnet1,
    aws_subnet.subnet2,
    aws_security_group.PUB-SG
  ]*/
description = "MySQL Access only from the Webserver Instances!"
  name = "private-db-sg"
  vpc_id  = data.aws_vpc.net.id
  tags = {
    Name = "Prod_DB_Security_Group"
  }

  # Created an inbound rule for MySQL
  ingress {
    description = "MySQL Access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.net.cidr_block]
  }


    ingress {
    description = "MySQL Access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.net.cidr_block]
  }
  # Created an inbound rule for SSH
ingress         {    
           
               cidr_blocks      = [
                   "0.0.0.0/0",
                ]
               description      = "Public"
               from_port        = 0
              # ipv6_cidr_blocks = []
              # prefix_list_ids  = []
               protocol         = "-1"
               #security_groups  = []
              #self             = false
               to_port          = 0
            }
  egress {
    description = "output from MySQL"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
/*
resource "aws_db_subnet_group" "publicsubgp" {
  name       = "main"
  /*subnet_ids = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id,
    aws_subnet.subnet3.id
  ]
  subnet_ids = [data.aws_subnet.net_private.id,data.aws_subnet.net_private1.id]
  tags = {
    Name = "My DB subnet group"
  }
}
*/
resource "aws_db_subnet_group" "privatesubgp" {
  name       = "private"

  subnet_ids = [data.aws_subnet.net_public.id,data.aws_subnet.net_public1.id]
  tags = {
    Name = "Prod_Subnet_Group"
  }

}
/*resource "aws_rds_cluster" "db_cluster" {
  cluster_identifier = "tagency"
  engine             = "mysql"
  engine_mode        = "provisioned"
  engine_version     = "8.0.28"
  database_name      = "tagency"
  master_username    = "admin"
  master_password    = "admin123"

}*/
/*resource "aws_rds_cluster_instance" "private_db" {
  cluster_identifier = aws_rds_cluster.private_db.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.db_cluster.engine
  engine_version     = aws_rds_cluster.example.engine_version
}*/

resource "aws_db_instance" "private_db" {
  identifier        = "tagency"
  allocated_storage    = 20
  max_allocated_storage = 1000
  engine               = "mysql"
  engine_version       = "8.0.28"
  instance_class       = "db.t3.micro"
  db_name                 = "tagency"
  username             = "admin"
  password             = "admin123"
  parameter_group_name = "default.mysql8.0"
  performance_insights_enabled  = false
  backup_retention_period = "7"
  storage_type = "gp2"
  skip_final_snapshot  = true
  #monitoring_interval = 5
  #monitoring_role_arn = "arn:aws:iam::747996363323:role/rds-monitoring-role"

  enabled_cloudwatch_logs_exports       = [
           "audit",
           "error",
           "general",
           "slowquery",
        ]
  #snapshot_identifier = "tagency"
  storage_encrypted = true
  copy_tags_to_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.privatesubgp.id
  publicly_accessible = true
  vpc_security_group_ids = [
  aws_security_group.PRV-SG.id
  ]
 tags = {
    db_Name = "tagency"
  }
}

/*
resource "aws_db_instance" "private_db1" {
  identifier        = "ms-opsexternal"
  allocated_storage    = 20
  max_allocated_storage = 1000
  engine               = "mysql"
  engine_version       = "8.0.28"
  instance_class       = "db.m5.large"
  db_name                 = "msopsexternal"
  username             = "admin"
  password             = "hXwfL8JZFvJ8sK9"
  parameter_group_name = "default.mysql8.0"
  performance_insights_enabled  = true
  backup_retention_period = "7"
  storage_type = "gp2"
  skip_final_snapshot  = true
  monitoring_interval = 5
  monitoring_role_arn = "arn:aws:iam::747996363323:role/rds-monitoring-role"

  enabled_cloudwatch_logs_exports       = [
           "audit",
           "error",
           "general",
           "slowquery",
        ]
 # snapshot_identifier = "ms-opsinternal"
  storage_encrypted = true
  copy_tags_to_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.privatesubgp.id
  publicly_accessible = false
  vpc_security_group_ids = [
  aws_security_group.PRV-SG.id
  ]
 tags = {
    db_Name = "MS-OpsExternal"
  }
}
resource "aws_db_instance" "private_db2" {
  identifier        = "ms-userexp"
  allocated_storage    = 20
  max_allocated_storage = 1000
  engine               = "mysql"
  engine_version       = "8.0.28"
  instance_class       = "db.m5.large"
  db_name                 = "msuserexp"
  username             = "admin"
  password             = "hXwfL8JZFvJ8sK9"
  parameter_group_name = "default.mysql8.0"
  performance_insights_enabled  = true
  backup_retention_period = "7"
  storage_type = "gp2"
  skip_final_snapshot  = true
  monitoring_interval = 5
  monitoring_role_arn = "arn:aws:iam::747996363323:role/rds-monitoring-role"

  enabled_cloudwatch_logs_exports       = [
           "audit",
           "error",
           "general",
           "slowquery",
        ]
 # snapshot_identifier = "ms-opsinternal"
  storage_encrypted = true
  copy_tags_to_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.privatesubgp.id
  publicly_accessible = false
  vpc_security_group_ids = [
  aws_security_group.PRV-SG.id
  ]
 tags = {
    db_Name = "MS-UserExp"
  }
}

*/
