# HCP Vault Radar Configuration

### Generate a GitHub Personal Access Token
Generate a Personal Access Token so that HCP Vault Radar can connect to the `vault-radar-demo` code repository.

Ensure the following scopes are selected:
- repo
- read:org
- admin:repo_hook
- admin:org_hook
- read:user


### Add repositories to Vault Radar
- Navigate to `Data Sources`, and add a new data source using the `HCP Vault Radar Scan` scanning method.
- Select `GitHub Cloud` from the available data sources.
- Enter `hashicorp-dev-advocates` for the GitHub organization
- Enter the GitHub PAT from the section above.
- Click `Select repositories to monitor`, and select `vault-radar-demo` from the list of discovered repositories.
- Click `Finish` in the top right

### Challenge
- For HashiConf 2025, we chose a specific secret as the target/clue
- Attendees will need to:
  - Find the user/email of the person who committed the secret
  - Find the plaintext value of the secret comitted
- We marked the specific secret as `Triaged` within the HCP Vault Radar dashboard
