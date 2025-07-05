data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "default" {
  default = true
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.public.id
}

output "private_subnets" {
  value = aws_subnet.private.id
}

output "database_subnets" {
  value = aws_subnet.database.id
}

output "route_table" {
  value = data.aws_vpc.default.main_route_table_id
}

output "azs"{
  value = data.aws_availability_zones.available
}
