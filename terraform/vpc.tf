#==============================================================================
# VIRTUAL PRIVATE CLOUD (VPC) CONFIGURATION
#==============================================================================
#
# This file creates the network foundation for the VGL application:
# - VPC with DNS support
# - Public subnets for load balancer
# - Private subnets for application containers
# - Database subnets for Aurora cluster
# - Internet and NAT gateways for connectivity
#
#==============================================================================

#------------------------------------------------------------------------------
# VPC - Main Network Container
#------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-vpc"
    Description = "Main VPC for VGL application infrastructure"
  })
}

#------------------------------------------------------------------------------
# Internet Gateway - Public Internet Access
#------------------------------------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-igw"
    Description = "Internet gateway for public subnet access"
  })
}

#------------------------------------------------------------------------------
# Public Subnets - Load Balancer Tier
#------------------------------------------------------------------------------

resource "aws_subnet" "public" {
  count = var.availability_zones
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-public-${count.index + 1}"
    Type        = "public"
    Tier        = "load-balancer"
    Description = "Public subnet for ALB in AZ ${count.index + 1}"
  })
}

#------------------------------------------------------------------------------
# Private Subnets - Application Tier
#------------------------------------------------------------------------------

resource "aws_subnet" "private" {
  count = var.availability_zones
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-private-${count.index + 1}"
    Type        = "private"
    Tier        = "application"
    Description = "Private subnet for ECS tasks in AZ ${count.index + 1}"
  })
}

#------------------------------------------------------------------------------
# Database Subnets - Data Tier
#------------------------------------------------------------------------------
resource "aws_subnet" "database" {
  count = var.availability_zones
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 20)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-${count.index + 1}"
    Type = "database"
  })
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? var.availability_zones : 0
  
  domain = "vpc"
  depends_on = [aws_internet_gateway.main]
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-eip-${count.index + 1}"
  })
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? var.availability_zones : 0
  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-${count.index + 1}"
  })
  
  depends_on = [aws_internet_gateway.main]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_route_table" "private" {
  count = var.availability_zones
  
  vpc_id = aws_vpc.main.id
  
  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id
    }
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-rt-${count.index + 1}"
  })
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count = var.availability_zones
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = var.availability_zones
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-subnet-group"
  })
}
