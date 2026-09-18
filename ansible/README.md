# Ansible - plateforme Prod

1. Installez Ansible sur le poste d'administration.
2. Générez l'inventaire à partir de l'Elastic IP Terraform :

   ```bash
   cd ansible
   bash generate_inventory.sh /chemin/absolu/vers/todo-ec2-key.pem
   ```

3. Remplacez les valeurs `*.example.com` dans `group_vars/prod.yml` par vos
   sous-domaines DNS.
4. Configurez les trois enregistrements DNS de type `A` vers l'Elastic IP
   affichée par Terraform : application, Grafana et SonarQube.
5. Vérifiez l'accès SSH et lancez le provisionnement :

   ```bash
   ansible prod -m ping
   ansible-playbook playbooks/provision.yml
   ```

Les mots de passe de Grafana et de la base SonarQube sont générés une seule fois
sur le serveur dans `/opt/examen/platform/.env`. Ils ne sont jamais commités.

