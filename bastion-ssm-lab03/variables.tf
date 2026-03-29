variable "instance_type" {
  type = string
  default = "t3.micro"
}

# choisir une adresse avec /32 pour signifier que c'est seule cette ip qui peut initier une conn vers bastion
# utiliser ma propre @ip public (de mon pc)
variable "admin_ip" {
  type = string
  default = "92.153.75.224/32"
}

# la region doit être la même que celle dans laquelle on a crée les subnets dans le lab02
variable "region" {
  type = string
  default = "eu-north-1"
}

# le nom d’une Key Pair déjà enregistrée dans AWS ou créer une ressource
variable "bastion_key_name" {
  type = string
  default = ""
}
