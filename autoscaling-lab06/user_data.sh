#!/bin/bash
set -eux

# Update system
yum update -y

# Install Apache
yum install -y httpd

# Enable and start Apache
systemctl enable httpd
systemctl start httpd

# Create demo index page (useful for ASG + ALB validation)
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
  <head>
    <title>Terraform ASG Demo</title>
  </head>
  <body>
    <h1>Hello from Terraform Day 12 ASG</h1>
    <p><strong>Instance ID:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
  </body>
</html>
EOF