#!/usr/bin/env bash
# Usage: ./create_project_structure.sh [target-directory]
# If target directory is omitted, defaults to ./postgres-cluster
set -euo pipefail

BASE=${1:-postgres-cluster}
echo "Creating project structure in $BASE"

# ----- directory tree -----
mkdir -p "$BASE"/{inventory,group_vars,playbooks,playbooks/roles}
mkdir -p "$BASE"/playbooks/roles/{common/etc,common/tasks}
mkdir -p "$BASE"/playbooks/roles/{etcd,patroni}/{tasks,templates}

# ----- top‑level files -----
touch "$BASE"/ansible.cfg

# ----- inventory -----
mkdir -p "$BASE"/inventory
cat <<'EOF' > "$BASE"/inventory/hosts.yml
all:
  children:
    db:
      hosts:
        vm-db1:
          ansible_host: 192.168.181.30
        vm-db2:
          ansible_host: 192.168.181.40
        vm-db3:
          ansible_host: 192.168.181.50
EOF

# ----- group_vars -----
cat <<'EOF' > "$BASE"/group_vars/all.yml
ansible_user: ubuntu
timezone: Europe/Moscow
EOF

cat <<'EOF' > "$BASE"/group_vars/etcd_cluster.yml
etcd_version: "3.5.14"
etcd_name_prefix: "db"
etcd_client_port: 2379
etcd_peer_port: 2380
EOF

cat <<'EOF' > "$BASE"/group_vars/patroni_cluster.yml
pg_version: 16
cluster_name: "demo-pg"
patroni_release: "3.4.2"
superuser_password: "StrongRoot!"
replicator_password: "ReplPass!"
EOF

# ----- playbooks -----
cat <<'EOF' > "$BASE"/playbooks/bootstrap.yml
---
- hosts: db
  become: yes
  roles:
    - common
    - etcd
    - patroni
EOF

# ----- roles/common/tasks -----
cat <<'EOF' > "$BASE"/playbooks/roles/common/tasks/main.yml
- name: Install base utilities
  apt:
    name:
      - curl
      - python3-psycopg2
      - jq
    state: present
    update_cache: yes
EOF

# ----- roles/etcd -----
cat <<'EOF' > "$BASE"/playbooks/roles/etcd/tasks/main.yml
# etcd install tasks go here
EOF

touch "$BASE"/playbooks/roles/etcd/templates/etcd.service.j2
touch "$BASE"/playbooks/roles/etcd/templates/etcd.conf.yml.j2

# ----- roles/patroni -----
cat <<'EOF' > "$BASE"/playbooks/roles/patroni/tasks/main.yml
# patroni install tasks go here
EOF

touch "$BASE"/playbooks/roles/patroni/templates/patroni.service.j2
touch "$BASE"/playbooks/roles/patroni/templates/patroni.yml.j2

echo "\nDone! Project skeleton created at $BASE"
