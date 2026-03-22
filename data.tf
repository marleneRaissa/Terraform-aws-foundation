# récupérer des informations dynamiquement relatif au vpc, Récupère tous les VPCs de votre compte AWS (car pas de filtre)
data "aws_vpc" "fetch_vpc" {}

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

# Liste de tous les IDs de subnets 
data "aws_subnets" "list_subnet" {
  filter {
    name   = "vpc-id" // keep the tag vpc-id
    values = [data.aws_vpc.fetch_vpc.id]
  }
}
