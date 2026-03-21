# Terraform Core Modules (Security Group & EC2)

## 🎯 Objectif

Conception des modules Terraform from scratch pour une bonne compréhension des fondamentaux de l'infrastructure AWS

## 🏗️ Architecture (High-Level)

```text
EC2 Instance
   │
   ├── Attached Security Groups
   │
   └── Subnet (provided externally)
```

## 🧱 What Was Built


### 1️⃣ Module de groupe de sécurité
Module de groupe de sécurité réutilisable prenant en charge :
- Règles entrantes et sortantes
- Trafic IPv4 et IPv6
- Règles dynamiques avec la boucle for_each
- Séparation claire des types de règles
- Configuration entièrement pilotée par variables


### 2️⃣ Module EC2
Un module EC2 réutilisable offrant :
- Une AMI Amazon Linux 2023 sélectionnée dynamiquement
- Type d’instance et sous-réseau configurables
- Paire de clés SSH optionnelle
- Association d’adresse IP publique optionnelle
- Étiquetage flexible avec étiquette de nom obligatoire
- Sorties claires pour l’intégration

---

## 🧠 Compétences démontrées

    ✅ Conception de modules Terraform
    ✅ Fonctionnement interne du groupe de sécurité AWS
    ✅ Ressources dynamiques avec for_each
    ✅ Modèles de variables map(object)
    ✅ Sources de données (aws_ami)
    ✅ Fusion de balises avec merge()
    ✅ Contrats d'entrée/sortie propres
    ✅ Réutilisabilité de l'infrastructure


## Exemple fonctionnement module security_group

variable "inbound_rules_ipv4" {
  default = {
    "http" = {
      cidr_ipv4   = "0.0.0.0/0"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      description = "HTTP from anywhere"
    }
    "https" = {
      cidr_ipv4   = "0.0.0.0/0"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      description = "HTTPS from anywhere"
    }
    "ssh_admin" = {
      cidr_ipv4   = "203.0.113.0/24"
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      description = "SSH from office"
    }
  }
}

```text
Variable inbound_rules_ipv4 (map)
│
├── "http" ────┐
├── "https" ───┤
└── "ssh_admin"┤
               │
               ▼
    for_each parcourt chaque clé
               │
               ▼
    Crée une ressource par règle
               │
               ▼
    Chaque règle est attachée au Security Group
               │
               ▼
    Résultat : 3 règles dans AWS
```

ce que Terraform va créer : 

# Ressource 1
resource "aws_vpc_security_group_ingress_rule" "ingress_rule_ip4"["http"] {
  security_group_id = sg-12345678
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  description       = "HTTP from anywhere"
}

# Ressource 2
resource "aws_vpc_security_group_ingress_rule" "ingress_rule_ip4"["https"] {
  security_group_id = sg-12345678
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  description       = "HTTPS from anywhere"
}

# Ressource 3
resource "aws_vpc_security_group_ingress_rule" "ingress_rule_ip4"["ssh_admin"] {
  security_group_id = sg-12345678
  cidr_ipv4         = "203.0.113.0/24"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description       = "SSH from office"
}
