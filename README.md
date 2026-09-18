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

## CI/CD et protection de `main`

Le code est développé sur `develop`, puis intégré à `main` exclusivement via
Pull Request. Les workflows des dépôts frontend et backend testent et
construisent l'application. Après une fusion dans `main`, ils utilisent AWS OIDC
et SSM pour reconstruire l'application sur l'EC2 Prod.

Après `terraform apply`, enregistrez dans les **GitHub Actions secrets** de
`examen_b` et `examen_f` :

- `AWS_DEPLOY_ROLE_ARN` : sortie Terraform `github_actions_deploy_role_arn` ;
- `AWS_PROD_INSTANCE_ID` : identifiant de l'instance EC2 Prod.

Dans `examen_b`, ajoutez aussi :

- `SONAR_HOST_URL` : `http://bayebaraexamensonarqub.duckdns.org` ;
- `SONAR_TOKEN` : token créé dans SonarQube pour l'analyse CI.

Dans GitHub, protégez ensuite la branche `main` : Pull Request obligatoire,
checks CI obligatoires, force push et suppression interdits.
