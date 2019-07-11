#!/usr/bin/env bash

cd /home/ubuntu/scripts
./run-vault.sh --dynamodb-table ${dynamodb_table} --tls-cert-file sample.cert --tls-key-file sample.key
