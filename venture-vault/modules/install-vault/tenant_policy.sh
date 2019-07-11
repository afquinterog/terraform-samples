#!/usr/bin/env bash
#export VAULT_TOKEN=$1
export VAULT_ADDR=http://127.0.0.1:8200
tenant_name=$2

read -d '' hcl_policy << EOF
path "secret/*" {
  capabilities = ["deny"]
}

path "secret/$tenant_name/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF

echo "$hcl_policy" | vault policy write "${tenant_name}_tenant_policy" -
