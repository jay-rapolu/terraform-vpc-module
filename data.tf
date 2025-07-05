data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "default" {
  default = true
}



output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "route_table" {
  value = data.aws_vpc.default.main_route_table_id
}

output "azs"{
  value = data.aws_availability_zones.available
}
