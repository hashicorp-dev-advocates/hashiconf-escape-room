export VAULT_ADDR=$(cd hcp-infrastructure && terraform output -json vault | jq -r .public_endpoint)
export VAULT_NAMESPACE=$(cd hcp-infrastructure && terraform output -json vault | jq -r .namespace)
export VAULT_TOKEN=$(cd vault-config && terraform output -raw token)