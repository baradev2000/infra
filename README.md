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

## Observabilité de production

Le playbook Ansible installe et configure automatiquement :

- **Prometheus** : CPU, RAM, disque, Traefik, cAdvisor, Nginx et endpoint
  Spring Boot Actuator ;
- **Grafana** : le dashboard `Todo - Production` est provisionné à chaque
  installation ;
- **Alertmanager** : reçoit les alertes `InstanceDown`, CPU/RAM/disque,
  conteneur, URL publique, backend et composants d'observabilité ;
- **Loki + Grafana Alloy** : centralisent les logs des conteneurs Docker ;
- **Tempo + OpenTelemetry Collector** : reçoivent les traces du backend ;
- **Nginx Prometheus Exporter** : expose les requêtes et connexions Nginx,
  sans rendre l'endpoint de statut public.

Dans Grafana, ouvrir le dashboard **Todo - Production** pour les métriques,
les alertes et les logs. Pour les traces, ouvrir **Explore**, sélectionner la
source **Tempo**, puis rechercher le service `todo-backend`. L'endpoint
`/actuator/prometheus` et le statut Nginx ne sont accessibles que sur les
réseaux Docker internes.

Alertmanager est volontairement livré avec un récepteur neutre : il affiche et
regroupe les alertes sans envoyer de notification externe. Pour recevoir des
notifications, ajouter ensuite un récepteur Telegram, email ou Slack dans
`ansible/files/alertmanager.yml`, sans y committer de secret.
