# Objectif final :
# permettre aux instances EC2 d’être gérées via AWS Systems Manager, notamment pour se connecter sans SSH avec Session Manager.


# Crée un rôle IAM utilisable par le service EC2 et définit qui a le droit d’utiliser ce rôle
resource "aws_iam_role" "ec2_ssm_role" {
  name               = "ec2-ssm-role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json  # qui peut utiliser le rôle ? une instance EC2 peut utiliser les permissions contenues dans ce rôle, Sans ça AWS ne peut pas savoir que ce rôle est destiné aux instances EC2
}

# Attache à ce rôle la permission AmazonSSMManagedInstanceCore nécessaires pour permettre à une EC2 d’être gérée par AWS Systems Manager sans SSH
resource "aws_iam_role_policy_attachment" "ec2_ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"  # ce que le rôle peut faire ()
}

# Instance profile used by EC2 for SSM
# Crée un Instance Profile pour pouvoir attacher/transmettre un rôle à une instance EC2 Pour qu’une instance précise l’utilise
resource "aws_iam_instance_profile" "ec2_ssm_instance_profile" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}