resource "aws_vpc" "prod" {
  cidr_block           = "10.50.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.tags, { Name = "${var.project_name}-prod-vpc" })
}

resource "aws_internet_gateway" "prod" {
  vpc_id = aws_vpc.prod.id

  tags = merge(local.tags, { Name = "${var.project_name}-prod-igw" })
}

resource "aws_subnet" "prod_public" {
  vpc_id                  = aws_vpc.prod.id
  cidr_block              = "10.50.10.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(local.tags, { Name = "${var.project_name}-prod-public" })
}

resource "aws_route_table" "prod_public" {
  vpc_id = aws_vpc.prod.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod.id
  }

  tags = merge(local.tags, { Name = "${var.project_name}-prod-public-rt" })
}

resource "aws_route_table_association" "prod_public" {
  subnet_id      = aws_subnet.prod_public.id
  route_table_id = aws_route_table.prod_public.id
}

resource "aws_eip" "prod" {
  domain   = "vpc"
  instance = aws_instance.prod.id

  tags = merge(local.tags, { Name = "${var.project_name}-prod-eip" })
}
