# Avantages de cette architecture :

## Client → HTTPS (port 443) → ALB (termine TLS) → HTTP (port 80) → Application

```text
```

CERTIFICAT ACM (stocké dans AWS)
├── Clé publique  → Donnée au navigateur (pour chiffrer)
└── Clé privée    → Gardée SECRÈTE dans l'ALB (pour déchiffrer)

L'ALB reçoit des données chiffrées → déchiffre avec clé privée → envoie en clair à l'application


À quoi ça sert ?
   Sert réellement l'application de manière sécurisée
   Termine la connexion TLS avec le certificat ACM
   Forward le trafic déchiffré vers les serveurs d'application

Si vous n'utilisiez pas ces ressources, vous devriez :
      - Gérer manuellement des certificats auto-signés (avertissements navigateur)
      - Ou acheter des certificats SSL ($$$)
      - Les renouveler manuellement tous les 90 jours
      - Configurer TLS sur chaque serveur d'application


# Parcours utilisateur

1. Utilisateur tape : http://leadrisehq.com
  
2. Listener HTTP (port 80) capture la requête
                  
3. Redirection 301 : https://leadrisehq.com
                  
4. Navigateur refait la requête en HTTPS
                  
5. Listener HTTPS (port 443) capture la requête sécurisée
   
6. Déchiffre avec le certificat ACM
   
7. Forward vers l'application (target group)
   
8. Réponse sécurisée retourne à l'utilisateur


✅ Avantages
Performance : L'ALB gère efficacement le chiffrement/déchiffrement
Simplification : Les applications ne gèrent pas le TLS (moins de configuration)
Sécurité : Un seul point à sécuriser et surveiller
Scalabilité : L'ALB distribue la charge SSL à travers plusieurs instances

❌ Sans le listener HTTP :
L'utilisateur qui tape http://leadrisehq.com verrait aucune réponse (timeout ou erreur)
Mauvaise expérience utilisateur
Perte de trafic


Récapitulatif : Le certificat dans le parcours
Étape	                                    Rôle du certificat
1. Utilisateur tape https://...	      Le navigateur demande le certificat
2. ALB envoie le certificat	            Prouve qu'il est bien leadrisehq.com
3. Navigateur vérifie le certificat	      Valide la signature AWS, les dates
4. Négociation TLS	                  Utilise le certificat pour chiffrer la session
5. Échange de données	                  Tout est chiffré grâce au certificat
6. Affichage	                        🔒 Cadenas vert car certificat valide


Sans certificat, pas de HTTPS possible. Avec certificat, l'utilisateur voit 🔒 et ses données sont protégées.