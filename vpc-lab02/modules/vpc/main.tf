# Provides a VPC resource.
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.project_name
    Env  = var.environment
  }

}

# Provides an VPC public subnet resource. Only public subnets are associated with the IGW route table
resource "aws_subnet" "public_subnets" {
  count                   = local.nb_of_public_subnets
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = local.derived_subnet_cidrs[count.index]
  availability_zone       = local.az_list[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name   = "${var.project_name}-public-${count.index + 1}"
    Env    = var.environment
    Subnet = "public"
  }
}

# Provides an VPC private subnet resource.
resource "aws_subnet" "private_subnets" {
  count                   = local.nb_of_private_subnets
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = local.derived_subnet_cidrs[count.index + 2]
  availability_zone       = local.az_list[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name   = "${var.project_name}-private-${count.index + 1}"
    Env    = var.environment
    Subnet = "private"
  }
}

/*
A subnet is public only if:
it has a route 0.0.0.0/0 → Internet Gateway
AND instances can receive public IPs
You already did the second part (map_public_ip_on_launch = true).
*/

# Provides a resource to create a VPC Internet Gateway.
# An Internet Gateway is a VPC-level construct.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Project = var.project_name
    Env     = var.environment
  }
}

# Provides a resource to create a VPC routing table.

# Public Route Table
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.main_vpc.id

  # 0.0.0.0/0 → IGW
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Project = var.project_name
    Env     = var.environment
  }
}

# Private Route Table : Cette table de routage privée (rt_private) dirige le trafic des ressources situées dans les sous-réseaux privés vers Internet via une NAT Gateway
resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.main_vpc.id

  # 0.0.0.0/0 → NAT Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Project = var.project_name
    Env     = var.environment
  }
}

// Provides a resource to create an association between a route table and a subnet 
// or a route table and an internet gateway or virtual private gateway.

resource "aws_route_table_association" "rta_public" {
  count          = local.nb_of_public_subnets
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.rt_public.id
  // If a subnet is associated with a route to an Internet Gateway, it is PUBLIC.
}

resource "aws_route_table_association" "rta_private" {
  count          = local.nb_of_private_subnets
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.rt_private.id
  // Private subnets go to NAT route table
}

# Provides an Elastic IP resource (Crée une adresse IP publique statique)
# Sans Elastic IP : La NAT Gateway aurait une IP publique qui change à chaque redémarrage → les instances privées perdraient leur accès Internet stable !
resource "aws_eip" "eip" {
  domain = "vpc"            // Indique que l'EIP est utilisable dans un VPC
  tags = {
    Project = var.project_name
    Env     = var.environment
  }
}

# Provides a resource to create a VPC NAT Gateway.
# NAT Gateway costs money per hour.

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id        // Crée une adresse IP publique statique attaché à NAT Gateway
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name    = "Public NAT-${var.project_name}-${var.project_name}"
    Project = var.project_name
    Env     = var.environment
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}