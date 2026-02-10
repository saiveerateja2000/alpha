# What Gets Created (Your Use Case)

## Your Configuration (in vars.tf)

```hcl
secrets = {
  "secret1" = {
    abc_username = "abc_user"
    abc_password = "RANDOM"
    def_username = "def_user"
    def_password = "RANDOM"
    token        = "RANDOM"
  }

  "secret2" = {
    aplha_username = "alpha_user"
    alpha_password = "RANDOM"
    beta_username  = "beta_user"
    beta_password  = "RANDOM"
    omega_username = "omega_user"
    omega_password = "RANDOM"
  }

  "secret3" = {
    service_user  = "service_account"
    service_token = "RANDOM"
    api_key       = "RANDOM"
    db_password   = "RANDOM"
  }
}
```

---

## What Terraform Creates in AWS Secrets Manager

### Secret 1: `secret1-abc123xyz` (auto-generated name)
```json
{
  "abc_username": "abc_user",
  "abc_password": "kJ7$mP2@xL9nQ4vR",
  "def_username": "def_user",
  "def_password": "tR3@zB8#sY5$pL1",
  "token": "qW7*fD4!mK6$nP9"
}
```

### Secret 2: `secret2-def456uvw` (auto-generated name)
```json
{
  "aplha_username": "alpha_user",
  "alpha_password": "sY5$pL1@tR3#zB8",
  "beta_username": "beta_user",
  "beta_password": "mK6$nP9*qW7!fD4",
  "omega_username": "omega_user",
  "omega_password": "xL9nQ4vR#kJ7@mP2"
}
```

### Secret 3: `secret3-ghi789rst` (auto-generated name)
```json
{
  "service_user": "service_account",
  "service_token": "abc123!@#def456",
  "api_key": "xyz789$%^ijk012",
  "db_password": "pqr345&*()stu678"
}
```

---

## How to Retrieve in Your Application

### Python
```python
import boto3
import json

client = boto3.client('secretsmanager', region_name='us-east-1')

# Get secret1
secret1 = json.loads(
    client.get_secret_value(SecretId='secret1-abc123xyz')['SecretString']
)

abc_user = secret1['abc_username']        # "abc_user"
abc_pass = secret1['abc_password']        # "kJ7$mP2@xL9nQ4vR"
my_token = secret1['token']               # "qW7*fD4!mK6$nP9"
```

### Node.js
```javascript
const AWS = require('aws-sdk');
const client = new AWS.SecretsManager({ region: 'us-east-1' });

const data = await client.getSecretValue({ SecretId: 'secret1-abc123xyz' }).promise();
const secret1 = JSON.parse(data.SecretString);

const abcUser = secret1.abc_username;
const abcPass = secret1.abc_password;
const token = secret1.token;
```

### Go
```go
package main

import (
    "encoding/json"
    "github.com/aws/aws-sdk-go/aws"
    "github.com/aws/aws-sdk-go/service/secretsmanager"
)

sess := session.Must(session.NewSession())
svc := secretsmanager.New(sess)

result, _ := svc.GetSecretValue(&secretsmanager.GetSecretValueInput{
    SecretId: aws.String("secret1-abc123xyz"),
})

var secret map[string]interface{}
json.Unmarshal([]byte(*result.SecretString), &secret)

abcUser := secret["abc_username"].(string)
abcPass := secret["abc_password"].(string)
```

---

## Terminal Commands

### Deploy
```bash
terraform init
terraform plan     # See what gets created
terraform apply    # Create all 3 secrets
```

### Get Secret Names (to use in apps)
```bash
terraform output secret_names

# Output:
# {
#   "secret1" = "secret1-abc123xyz"
#   "secret2" = "secret2-def456uvw"
#   "secret3" = "secret3-ghi789rst"
# }
```

### Get Secrets via AWS CLI
```bash
# Retrieve secret1 and extract username
aws secretsmanager get-secret-value \
  --secret-id secret1-abc123xyz \
  --query 'SecretString | fromjson.abc_username' \
  --output text
# Output: abc_user

# Retrieve password
aws secretsmanager get-secret-value \
  --secret-id secret1-abc123xyz \
  --query 'SecretString | fromjson.abc_password' \
  --output text
# Output: kJ7$mP2@xL9nQ4vR
```

---

## Customization Examples

### Add a 4th Secret
```hcl
secrets = {
  ...(above 3 secrets)
  "secret4" = {
    github_token   = "RANDOM"
    github_username = "devops_bot"
  }
}

terraform apply  # Instantly creates secret4!
```

### Add More Fields to Existing Secret
```hcl
"secret1" = {
  abc_username = "abc_user"
  abc_password = "RANDOM"
  def_username = "def_user"
  def_password = "RANDOM"
  token        = "RANDOM"
  backup_token = "RANDOM"  # Add this!
}

terraform apply  # Updates secret1 with backup_token
```

### Mix Static and Random in Any Order
```hcl
"app-config" = {
  env          = "production"        # Static
  debug        = "false"             # Static
  api_endpoint = "https://api.com"   # Static
  db_password  = "RANDOM"            # Random
  secret_key   = "RANDOM"            # Random
  region       = "us-east-1"         # Static
}
```

---

## How Many Random Passwords Are Generated?

**Your current setup:**
- Secret1: 3 random passwords (abc_password, def_password, token)
- Secret2: 3 random passwords (alpha_password, beta_password, omega_password)
- Secret3: 3 random passwords (service_token, api_key, db_password)

**Total: 9 unique random passwords generated automatically** ✅

Each one is **16 characters with special characters**, randomly generated, and secure.

---

## Summary

✅ Define secrets once in vars.tf
✅ Use "RANDOM" for any field that needs auto-generation
✅ Run `terraform apply` - all 3 secrets created instantly
✅ Each field marked "RANDOM" gets a unique 16-char password
✅ Works for ANY number of secrets and fields
✅ Works for ANY combination of static + random values
