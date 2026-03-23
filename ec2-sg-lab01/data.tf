# AWS crée automatiquement un VPC par défaut dans chaque région lorsque vous créez votre compte AWS !
# récupérer des informations dynamiquement relatif au vpc par defaut, Récupère tous les VPCs de votre compte AWS (car pas de filtre)
data "aws_vpc" "fetch_vpc" {
   default = true  # Récupère explicitement le VPC par défaut
}

# récupérer dynamiquement des informations du security_group présent par defaut  dans aws
# on pourra l'utiliser pour le reférencer ailleurs dans une une ressource
data "aws_security_group" "default_sg" {
  filter {
    name   = "group-name"
    values = ["default"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.fetch_vpc.id]
  }
}

# récupérer dynamiquement tous les subnets du VPC par défaut
data "aws_subnets" "list_subnet" {
  filter {
    name   = "vpc-id" // keep the tag vpc-id
    values = [data.aws_vpc.fetch_vpc.id]
  }
}

# Récupérer les détails de chaque subnet
data "aws_subnet" "subnet_details" {
  for_each = toset(data.aws_subnets.list_subnet.ids)
  id       = each.value
}

# Ajouter/Modifier les tags des subnets existants (SANS recréation)
resource "aws_ec2_tag" "subnet_name" {
  for_each = data.aws_subnet.subnet_details
  resource_id = each.value.id
  key         = "Name"
  value       = "lab01-${each.value.id}"
}
