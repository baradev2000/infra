# Infrastructure de production

Cette infrastructure crée une EC2 AWS dédiée à l'environnement **Prod** de
l'application Todo. L'instance accueillera Docker, Traefik, SonarQube,
Prometheus et Grafana, installés à l'étape Ansible.

## Prérequis

- AWS CLI configuré avec un compte autorisé à créer des ressources EC2/IAM.
- Une paire de clés EC2 existante dans la région choisie.
- Terraform >= 1.6.

## Créer le serveur

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# renseigner key_name et admin_cidr dans terraform.tfvars
terraform init
terraform plan
terraform apply
```

Après `apply`, l'adresse du serveur est disponible avec :

```bash
terraform output -raw prod_public_ip
```

Cette IP sera utilisée par Ansible à l'étape suivante.

> Ne versionnez jamais `terraform.tfvars`, les fichiers `*.tfstate` ou une clé
> privée EC2.

