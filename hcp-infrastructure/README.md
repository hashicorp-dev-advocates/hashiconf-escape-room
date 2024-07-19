# HCP infrastructure & AWS IAM resources

This directory sets up the HCP clusters, service principals, and HCP Vault Secrets
applications.

It also creates OIDC providers in AWS for HCP Terraform and GitHub Actions
(used for Packer).

## Required credentials

- `AWS_*`: Service account with IAM policy.

  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateOpenIDConnectProvider",
                "iam:GetOpenIDConnectProvider",
                "iam:ListOpenIDConnectProviders",
                "iam:UpdateOpenIDConnectProviderThumbprint",
                "iam:DeleteOpenIDConnectProvider",
                "iam:AddClientIDToOpenIDConnectProvider",
                "iam:RemoveClientIDFromOpenIDConnectProvider",
                "iam:TagOpenIDConnectProvider",
                "iam:CreateRole",
                "iam:GetRole",
                "iam:UpdateRole",
                "iam:DeleteRole",
                "iam:ListRoles",
                "iam:TagRole",
                "iam:ListRolePolicies",
                "iam:ListAttachedRolePolicies",
                "iam:ListInstanceProfilesForRole",
                "iam:PutRolePolicy",
                "iam:GetRolePolicy",
                "iam:DeleteRolePolicy",
                "iam:CreatePolicy",
                "iam:AttachRolePolicy",
                "iam:TagPolicy",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:ListPolicyVersions",
                "iam:DeletePolicy",
                "iam:UpdateAssumeRolePolicy",
                "iam:CreatePolicyVersion",
                "iam:DeletePolicyVersion"
            ],
            "Resource": "*"
        }
    ]
  }
  ```

- `TFE_TOKEN`: Team token with private registry permissions to manage modules
- `HCP_CLIENT_*`: HCP service principal with `Project Admin` access

