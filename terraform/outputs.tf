output "prod_public_ip" {
  description = "Elastic IP stable à utiliser pour Ansible et les enregistrements DNS."
  value       = aws_eip.prod.public_ip
}

output "ansible_host" {
  description = "Hôte SSH de production pour l'inventaire Ansible."
  value = {
    ansible_host = aws_eip.prod.public_ip
    ansible_user = "ec2-user"
  }
}
