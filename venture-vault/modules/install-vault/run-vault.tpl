#!/usr/bin/env bash
cd /opt/vault/bin
sudo ./run-vault --dynamodb-table ${dynamodb_table} \
    --tls-cert-file sample.cert --tls-key-file sample.key \
    --enable-auto-unseal \
    --auto-unseal-kms-key-id ${kms_key} \
    --auto-unseal-kms-key-region ${aws_region}
