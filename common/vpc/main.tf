# Get available AZs
data "aws_availability_zones" "available" {
}
# Get VPC cidr
data "aws_vpc" "selected" {
  id = var.vpc_id
}

locals {
  # Create IGW
  create_igw          = var.igw == ""
  cidr_for_subnetting = var.custom_cidr == "" ? data.aws_vpc.selected.cidr_block : var.custom_cidr

  # Public subnet no
  public_subnet_no = (var.public_subnets ? 1 : 0) * var.azs_number
  # Private subnet no
  private_subnet_no = length(var.private_subnets) * var.azs_number
  # Total subnet no
  subnet_no = local.public_subnet_no + local.private_subnet_no

  # Cidr blocks
  public_cidr_blocks  = [for i in range(local.public_subnet_no) : cidrsubnet(local.cidr_for_subnetting, local.subnet_no, i)]
  private_cidr_blocks = [for i in range(local.private_subnet_no) : cidrsubnet(local.cidr_for_subnetting, local.subnet_no, i + local.public_subnet_no)]
}

resource "aws_subnet" "public" {
  count                   = local.public_subnet_no
  vpc_id                  = var.vpc_id
  cidr_block              = local.public_cidr_blocks[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index % var.azs_number]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  count  = local.create_igw && var.public_subnets ? 1 : 0
  vpc_id = var.vpc_id
  tags = {
    Name = "Internet Gateway"
  }
}

resource "aws_route_table" "public" {
  count  = var.public_subnets ? 1 : 0
  vpc_id = var.vpc_id
  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_rtb_assoc" {
  count          = local.public_subnet_no
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route" "public_route" {
  count = local.public_subnet_no

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = local.create_igw ? aws_internet_gateway.igw[0].id : var.igw
}

resource "aws_subnet" "private" {
  for_each = merge(flatten([
    for i in range(length(var.private_subnets)) : {
      for j in range(var.azs_number) : "${var.private_subnets[i].name}-${j + 1}" => {
        cidr  = local.private_cidr_blocks[i * var.azs_number + j]
        az    = data.aws_availability_zones.available.names[j]
        name  = var.private_subnets[i].name
        az_no = j + 1
      }
    }
  ])...)
  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${title(each.value.name)} subnet ${each.value.az_no}"
  }
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = var.vpc_id
  tags = {
    Name = "Private Route Table ${each.key}"
  }
}

resource "aws_route_table_association" "private_route" {
  for_each = aws_route_table.private

  route_table_id = each.value.id
  subnet_id      = aws_subnet.private[each.key].id
}

resource "aws_eip" "nat" {
  for_each = var.private_subnets[0].internet ? toset([
    for i in range(var.azs_number) : "${var.private_subnets[0].name}-${i + 1}"
  ]) : toset([])
}

resource "aws_nat_gateway" "nat" {
  count         = length(keys(aws_eip.nat))
  allocation_id = aws_eip.nat[keys(aws_eip.nat)[count.index]].id
  subnet_id     = aws_subnet.public[count.index].id
}

resource "aws_route" "private_internet" {
  for_each = merge(flatten([
    for i in range(length(var.private_subnets)) : {
      for j in range(var.azs_number) : "${var.private_subnets[i].name}-${j + 1}" => {
        nat_id         = j
        route_table_id = aws_route_table.private["${var.private_subnets[i].name}-${j + 1}"].id
      }
    } if var.private_subnets[i].internet
  ])...)

  route_table_id         = each.value.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[each.value.nat_id].id
}

# Create s3 gateway endpoint
data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
  filter {
    name   = "service-type"
    values = ["Gateway"]
  }
}
resource "aws_vpc_endpoint" "s3" {
  count        = var.gateway_endpoints ? 1 : 0
  service_name = data.aws_vpc_endpoint_service.s3.service_name
  vpc_id       = var.vpc_id
  auto_accept  = true
  tags = {
    Name = "S3 Gateway Endpoint"
  }
}
data "aws_vpc_endpoint_service" "dynamodb" {
  service = "dynamodb"
  filter {
    name   = "service-type"
    values = ["Gateway"]
  }
}
resource "aws_vpc_endpoint" "dynamodb" {
  count        = var.gateway_endpoints ? 1 : 0
  service_name = data.aws_vpc_endpoint_service.dynamodb.service_name
  vpc_id       = var.vpc_id
  auto_accept  = true
  tags = {
    Name = "Dynamodb Gateway Endpoint"
  }
}
resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  for_each        = var.gateway_endpoints ? aws_route_table.private : {}
  route_table_id  = each.value.id
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
}
resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = var.gateway_endpoints && var.public_subnets ? 1 : 0

  route_table_id  = aws_route_table.public[0].id
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
}
resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  for_each        = var.gateway_endpoints ? aws_route_table.private : {}
  route_table_id  = each.value.id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
}
resource "aws_vpc_endpoint_route_table_association" "public_dynamodb" {
  count = var.gateway_endpoints && var.public_subnets ? 1 : 0

  route_table_id  = aws_route_table.public[0].id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[0].id
}