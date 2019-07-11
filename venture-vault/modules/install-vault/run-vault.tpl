#!/usr/bin/env bash

cd /opt/vault/bin
sudo ./run-vault --dynamodb-table ${var.dynamodb_table} --tls-cert-file sample.cert --tls-key-file sample.key
