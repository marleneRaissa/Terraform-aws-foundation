variable "security_group_name" {
  type = string
}

variable "security_group_description" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "inbound_rules_ipv4" {

  type = map(object({

    cidr_ipv4   = string
    protocol    = string
    from_port   = number
    to_port     = number
    description = string

  }))
  default = {}

}

variable "inbound_rules_ipv6" {

  type = map(object({

    cidr_ipv6   = string
    protocol    = string
    from_port   = number
    to_port     = number
    description = string

  }))
  default = {}

}

variable "inbound_rules_sg" {

  type = map(object({

    referenced_security_group_id = string
    protocol                     = string
    from_port                    = number
    to_port                      = number
    description                  = string

  }))
  default = {}

}

variable "outbound_rules_ipv4" {

  type = map(object({
    cidr_ipv4   = string
    protocol    = string
    from_port   = number
    to_port     = number
    description = string
  }))
  default = {}

}

variable "outbound_rules_ipv6" {

  type = map(object({
    cidr_ipv6   = string
    protocol    = string
    from_port   = number
    to_port     = number
    description = string
  }))
  default = {}

}

variable "outbound_rules_sg" {

  type = map(object({
    referenced_security_group_id = string
    protocol                     = string
    from_port                    = number
    to_port                      = number
    description                  = string
  }))
  default = {}

}

variable "tags" {
  type    = map(string)
  default = {}
}