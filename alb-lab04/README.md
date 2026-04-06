# configure une partie de l'infrastructure pour un Application Load Balancer (ALB) sur AWS. 


À quoi ça sert ?
      - Capture tout le trafic HTTP non sécurisé
      - Ne sert jamais l'application directement
      - Redirige immédiatement l'utilisateur vers la version HTTPS

Pourquoi est-ce nécessaire ?
      - Les utilisateurs peuvent taper http://leadrisehq.com ou juste leadrisehq.com (par défaut HTTP)
      - Sans ça, ils verraient une erreur ou une version non sécurisée
      - Améliore l'expérience utilisateur (redirection automatique)


1. Vous tapez : http://leadrisehq.com
   
2. Serveur répond : "301 Moved Permanently" (L'utilisateur ne voit jamais le code 301. C'est une communication machine-machine invisible.)

   Location: https://leadrisehq.com
   
3. Votre navigateur reçoit cette réponse
   
4. Navigateur fait AUTOMATIQUEMENT une nouvelle requête vers : https://leadrisehq.com
   
5. Le site s'affiche ENFIN (sur HTTPS)



```text
Internet → ALB (port 80) → Listener (redirige vers HTTPS)
                    ↓
              ALB (port 443) → Target Group → Instances EC2 (port 80)
                                    ↑
                              (health checks réguliers)
```







AWS propose 3 types de load balancers, chacun avec des capacités différentes :

Type	                              Valeur	    Utilisation	Protocoles
Application Load Balancer (ALB)	application     App web, routage avancé (par chemin, hôte), HTTP, HTTPS	

Network Load Balancer (NLB)	      network         Très hautes performances, low latency, TCP/UDP, TCP, UDP, TLS

Gateway Load Balancer (GWLB)	      gateway	    Déploiement d'appliances réseau (firewalls)
