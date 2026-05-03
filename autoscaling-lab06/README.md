# Autoscalling
Un groupe d'auto-scaling EC2 est un ensemble logique de plusieurs instances Amazon EC2 utilisé à des fins de gestion et de mise à l'échelle.

Au-delà de ces fonctionnalités de base, vous pouvez utiliser une stratégie de mise à l'échelle pour modifier dynamiquement la taille du groupe, en appliquant des stratégies pour les tâches suivantes :
      - Mise à l'échelle manuelle
      - Maintien d'un nombre fixe et prédéfini d'instances
      - Suivi d'un objectif pour un indicateur de charge spécifique
      - Mise à l'échelle par paliers en fonction de plusieurs seuils d'un indicateur de charge
      - Mise à l'échelle simple (modification de la capacité par incréments fixes)
      - Tâches de mise à l'échelle basées sur les files d'attente SQS
      - Mise à l'échelle planifiée
      - Lorsqu'une stratégie est active, le groupe de mise à l'échelle automatique modifie dynamiquement le nombre d'instances, en le maintenant entre les valeurs maximale et minimale définies pour votre groupe.


## Launch Templates
Les groupes à dimensionnement automatique utilisent des modèles de lancement pour définir quelles nouvelles instances seront lancées. Vous pouvez définir un type d'instance spécifique, ou plusieurs types d'instances, dans un modèle de lancement. Vous pouvez également configurer différents modèles de lancement pour différentes ressources EC2.


## Auto scaling groups and availability zones
Vous pouvez étendre des groupes de mise à l'échelle automatique sur plusieurs zones de disponibilité (AZ) au sein d'une région. L'étape suivante consiste à associer un équilibreur de charge, qui répartit le trafic entrant de manière égale entre toutes les AZ sélectionnées.

Lorsqu'une AZ devient indisponible ou défaillante, la mise à l'échelle automatique lance et ajoute de nouvelles instances à la AZ la moins chargée. Si ces tentatives échouent, la mise à l'échelle automatique essaie de lancer ces instances dans d'autres AZ et poursuit ce processus jusqu'à ce qu'il réussisse.

Pour augmenter la disponibilité de votre application, vous pouvez ajouter une AZ à votre groupe de mise à l'échelle automatique. N'oubliez pas d'activer cette AZ pour l'équilibreur de charge concerné. Une fois la nouvelle AZ activée, l'équilibreur de charge répartit le trafic de manière égale entre toutes les AZ activées.

Notez que si les groupes de mise à l'échelle automatique peuvent contenir des instances provenant de plusieurs AZ, toutes les AZ doivent se trouver dans la même région. Cette fonctionnalité ne prend pas en charge l'utilisation de plusieurs régions.


Voici d'autres limitations à prendre en compte lors du choix des zones de disponibilité (AZ) :
      - Lors de l'activation d'une AZ pour votre équilibreur de charge, vous devez définir un sous-réseau au sein de cette AZ. Cependant, vous ne pouvez sélectionner qu'un seul sous-réseau par AZ.

      - Tout sous-réseau spécifié pour les équilibreurs de charge exposés à Internet doit disposer d'au moins huit adresses IP disponibles.

      - Les équilibreurs de charge d'application nécessitent au moins deux AZ activées.

      - Il est impossible de désactiver les AZ activées pour les équilibreurs de charge réseau. Vous pouvez en revanche activer des AZ supplémentaires.

      - Les équilibreurs de charge de passerelle ne prennent pas en charge les modifications apportées aux AZ ou aux sous-réseaux ajoutés lors de la création de l'équilibreur de charge.

