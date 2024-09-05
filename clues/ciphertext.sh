#!/bin/bash

export VAULT_ADDR=$(cd hcp-infrastructure && terraform output -json vault | jq -r '.public_endpoint')
export VAULT_TOKEN=$(cd vault-config && terraform output -raw token)
export VAULT_NAMESPACE=admin

vault write transit/encrypt/escape-rooms plaintext=$(echo "${1}" | base64) context=$(echo '{"foo":"bar"}' | base64)