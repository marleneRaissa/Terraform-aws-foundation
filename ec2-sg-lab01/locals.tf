# Liste de tous les IDs de subnets Prend le premier élément de la liste, Stocke cet ID dans une variable locale nommée first_subnet_id
locals {
  first_subnet_id = data.aws_subnets.list_subnet.ids[0]
}