# ce script permet de vérifier que : ALB fonctionne, Target Group fonctionne, ASG crée bien les instances, Apache répond bien, le trafic arrive bien sur les instances

#!/bin/bash
set -eux

# Update system
yum update -y

# Install Apache
yum install -y httpd

# Enable and start Apache
systemctl enable httpd
systemctl start httpd

# Get EC2 metadata token for IMDSv2
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Get instance ID using IMDSv2 token
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)


# Pourquoi afficher l’Instance ID ? C’est très utile avec un Auto Scaling Group + ALB.
# Si ton ALB envoie le trafic vers plusieurs instances, tu peux rafraîchir la page 
# plusieurs fois et voir si tu tombes sur différentes instances : 
# Refresh 1 → Instance ID: i-aaa111, Refresh 2 → Instance ID: i-bbb222, Refresh 3 → Instance ID: i-ccc333

# Create demo index page (useful for ASG + ALB validation)
# Demande au service de métadonnées AWS l’ID de cette instance EC2
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
  <head>
    <title>Terraform ASG Demo</title>
  </head>
  <body>
    <h1>Hello from Terraform Day 12 ASG</h1>
    <p><strong>Instance ID:</strong> ${INSTANCE_ID}</p>
  </body>
</html>
EOF