#!/usr/bin/env bash
set -euo pipefail

key_path="${1:?Usage: bash generate_inventory.sh /absolute/path/to/todo-ec2-key.pem}"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
infrastructure_dir="$(cd -- "${script_dir}/.." && pwd)"
prod_ip="$(terraform -chdir="${infrastructure_dir}/terraform" output -raw prod_public_ip)"

cat > "${script_dir}/inventory.yml" <<EOF
all:
  children:
    prod:
      hosts:
        todo-prod:
          ansible_host: ${prod_ip}
          ansible_user: ec2-user
          ansible_ssh_private_key_file: ${key_path}
          ansible_ssh_common_args: -o IdentitiesOnly=yes
EOF

echo "Inventaire créé pour ${prod_ip}: ${script_dir}/inventory.yml"

