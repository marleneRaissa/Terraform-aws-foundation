variable "region" {
  type = string
  default = "eu-north-1"
}

variable "environment" {
  type = string
  description = "variable to set environment: prod, dev"
  default = "dev"
}

variable "instance_type" {
  type = string
  description = "To set the instance type of the EC2 instance"
  default = "t3.micro"
}

variable "ssh_key_name" {
  type = string
  default = null
}

# permet de passer des tags (étiquettes) à une ressource ou un module de manière flexible et standardisée
#Exemple : { "Environment" = "Production", "Project" = "MonApp" }

variable "tags" { 
  type = map(string)
  default = {}
}
