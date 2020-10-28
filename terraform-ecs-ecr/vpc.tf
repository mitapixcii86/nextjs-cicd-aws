resource "aws_vpc" "devops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "devops-vpc-nextjs-app"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devops_vpc.id
  tags = {
    Name = "igw"
  }
}

# Providing a reference to our default subnets
resource "aws_subnet" "devops_subnet" {
  availability_zone       = "eu-central-1a"
  cidr_block              = element(var.subnets_cidr, count.index)
  count                   = length(var.azs)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.devops_vpc.id
  tags = {
    Name = "subnet-devops-a"
  }
  depends_on = [
    aws_internet_gateway.igw
  ]
}

data "aws_subnet_ids" "devops_subnet_id" {
  depends_on = [aws_subnet.devops_subnet]
  vpc_id     = aws_vpc.devops_vpc.id
}

# resource "aws_subnet" "devops_subnet_b" {
#   availability_zone       = "eu-central-1b"
#   cidr_block              = element(var.subnets_cidr, 1)
#   map_public_ip_on_launch = true
#   vpc_id                  = aws_vpc.devops_vpc.id
#   tags = {
#     Name = "subnet-devops-b"
#   }
#   depends_on = [
#     aws_internet_gateway.igw
#   ]
# }

# resource "aws_subnet" "devops_subnet_c" {
#   availability_zone       = "eu-central-1c"
#   cidr_block              = element(var.subnets_cidr, 2)
#   map_public_ip_on_launch = true
#   vpc_id                  = aws_vpc.devops_vpc.id
#   tags = {
#     Name = "subnet-devops-c"
#   }
#   depends_on = [
#     aws_internet_gateway.igw
#   ]
# }

# main route table for vpc and subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.devops_vpc.id
  tags = {
    Name = "public_route_table_main"
  }
}

# add public gateway to the route table
resource "aws_route" "public" {
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
}

# associate route table with vpc
resource "aws_main_route_table_association" "public" {
  vpc_id         = aws_vpc.devops_vpc.id
  route_table_id = aws_route_table.public.id
}

# and associate route table with each subnet
resource "aws_route_table_association" "public" {
  count          = length(var.azs)
  subnet_id      = sort(data.aws_subnet_ids.devops_subnet_id.ids)[count.index]
  route_table_id = aws_route_table.public.id
}

# create elastic IP (EIP) to assign it the NAT Gateway 
resource "aws_eip" "devops_eip" {
  count      = length(var.azs)
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

# create NAT Gateways
# make sure to create the nat in a internet-facing subnet (public subnet)
resource "aws_nat_gateway" "devops" {
  count         = length(var.azs)
  allocation_id = element(aws_eip.devops_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.devops_subnet.*.id, count.index)
  depends_on    = [aws_internet_gateway.igw]
}