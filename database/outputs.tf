#Mapping outputs to modularize

output "rds_endpoint" {
  value = "${aws_db_instance.appserver-db.endpoint}"
}