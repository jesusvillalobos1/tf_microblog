#Mapping outputs to modularize

output "app_vpc" {
  value = aws_vpc.app_vpc.id
}

output "pub_sub1" {
  value = aws_subnet.pub_sub1.id
}

output "pub_sub2" {
  value = aws_subnet.pub_sub2.id
}

output "prv_sub1" {
  value = aws_subnet.prv_sub1.id
}

output "prv_sub2" {
  value = aws_subnet.prv_sub2.id
}

output "database-subnet-1" {
   value = aws_subnet.database-subnet-1.id 
}

output "database-subnet-2" {
   value = aws_subnet.database-subnet-2.id 
}

output "app-rds-sng" {
  value = aws_db_subnet_group.app-rds-sng.id
}

output "igw" {
  value = aws_internet_gateway.igw.id
}

output "pub_sub1_rt" {
  value = aws_route_table.pub_sub1_rt.id
}

output "elb_sg" {
  value =aws_security_group.elb_sg.id
}
