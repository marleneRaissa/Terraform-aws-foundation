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

