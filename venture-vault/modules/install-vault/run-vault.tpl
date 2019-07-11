#!/usr/bin/env bash

cd /opt/vault/bin
sudo ./run-vault --dynamodb-table vault-base-db --tls-cert-file sample.cert --tls-key-file sample.key
