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
resource "aws_subnet" "devops_subnet_a" {
  availability_zone       = "eu-central-1a"
  cidr_block              = element(var.subnets_cidr, 0)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.devops_vpc.id
  tags = {
    Name = "subnet-devops-a"
  }
  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_subnet" "devops_subnet_b" {
  availability_zone       = "eu-central-1b"
  cidr_block              = element(var.subnets_cidr, 1)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.devops_vpc.id
  tags = {
    Name = "subnet-devops-b"
  }
  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_subnet" "devops_subnet_c" {
  availability_zone       = "eu-central-1c"
  cidr_block              = element(var.subnets_cidr, 2)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.devops_vpc.id
  tags = {
    Name = "subnet-devops-c"
  }
  depends_on = [
    aws_internet_gateway.igw
  ]
}