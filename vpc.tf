resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  instance_tenancy = "default"

  tags = merge(
    local.common_variables,
    {
    Name = "${var.project}-${var.environment}"
    }
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_variables,
    {
      Name = "${var.project}-${var.environment}-public-${data.aws_availability_zones.available.names[count.index]}"
    }
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    local.common_variables,
    {
      Name = "${var.project}-${var.environment}-private-${data.aws_availability_zones.available.names[count.index]}"
    }
  )
}

resource "aws_subnet" "database" {
  count = length(var.database_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    local.common_variables,
    {
      Name = "${var.project}-${var.environment}-database-${data.aws_availability_zones.available.names[count.index]}"
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_variables,
    {
      Name = "${var.project}-${var.environment}"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_variables,
    {
      Name = "${var.project}-${var.environment}-public"
    }
  )
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "main"{
  tags = merge(
    local.common_variables,
    {
      Name = "${var.project}-${var.environment}"
    }
  )
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    local.common_variables,
    {
      Name = "${var.project}-${var.environment}"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    local.common_variables,
    {
      Name = "${var.project}-${var.environment}-private"
    }
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    local.common_variables,
    {
      Name = "${var.project}-${var.environment}-database"
    }
  )
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(aws_subnet.database)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}
