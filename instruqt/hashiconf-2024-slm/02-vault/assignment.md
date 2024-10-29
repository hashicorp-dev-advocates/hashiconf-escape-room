---
slug: vault
id: wgjevy6jyd8q
type: challenge
title: Keep one secret at a time.
teaser: Vault
notes:
- type: text
  contents: Time to unlock the first clue using Vault.
tabs:
- id: wrbdb5ei2uw7
  title: Terminal
  type: terminal
  hostname: sandbox
difficulty: ""
enhanced_loading: null
---
Before starting, log into Vault.

```run
export VAULT_TOKEN=$(cat ~/.vault_token)
```

This will set up the environment to access Vault.

# Clue

Decrypt the clue in the ciphertext

```
vault:v1:UC0z/bCqBM5qkW1eedxwWdvK96aC6K/3iNcUgJSXNs1UM6HS+ULYqkyevpGiOG46s45MCVJ33QeyX6+Qf32wjUNFJcwEKP3vNPa6MCWMh2b9Ldj/ToN8ZLPiTb/P78OMTA==
```

using Vault's transit secrets engine for the location of the first set of two digits to unlock the room.

You can find the decryption key at `transit/decrypt/escape-rooms` and use the key context stored in the `${CONTEXT}` environment variable.

Click "Next" to go to the next clue.

Credentials
===
If you need to log into Vault, Consul, or Boundary, print out the credentials using:

```run
creds
```

Hint
===
Decrypt the ciphertext using Vault's transit secrets engine.

```
vault write -field=plaintext <set path to key> ciphertext=<set to ciphertext> context=${CONTEXT} | base64 -d
```