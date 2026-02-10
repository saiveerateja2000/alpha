# Real-World Example: Multi-Environment Secret Management

## Scenario
Your company has 3 applications running in production, each needing database credentials. You need to:
- Store credentials securely in AWS Secrets Manager
- Auto-generate strong passwords (never hardcode them)
- Store multiple values per secret (username, password, host, port)
- Deploy to multiple environments without manual copy-pasting

---

## Without Terraform (Manual Way - ❌ Bad)

### Step 1: Generate password manually
```bash
# Generate 16 random chars... how?
password = "kJ7$mP2@xL9nQ4vR"
```

### Step 2: Create each secret manually in AWS Console
- Login to AWS Console
- Go to Secrets Manager
- Click "Create new secret"
- Paste the values manually
- Copy the ARN
- Do this 3 times for 3 apps...

### Step 3: Update app configs manually
```yaml
# app1-config.yaml
DB_HOST: db.prod.aws.com
DB_USER: admin1
DB_PASSWORD: kJ7$mP2@xL9nQ4vR
DB_PORT: 5432

# app2-config.yaml
DB_HOST: db.prod.aws.com
DB_USER: admin2
DB_PASSWORD: # What was this again?? 😅

# app3-config.yaml
# Copy-paste error? Different password? Manual mistake?
```

### Problems:
- 🚨 Error-prone (manual mistakes)
- 🚨 No tracking of who created what
- 🚨 Passwords might be hardcoded in configs
- 🚨 Recreating in another region = repeat everything
- 🚨 No version control
- 🚨 Takes 30+ minutes per environment

---

## With Terraform (✅ Automated Way)

### Step 1: Define once in code
```hcl
# vars.tf
secrets = {
  "app1-db" = {
    username = "app1_admin"
    host     = "db.prod.aws.com"
    port     = "5432"
    database = "app1_db"
  }
  "app2-db" = {
    username = "app2_admin"
    host     = "db.prod.aws.com"
    port     = "5432"
    database = "app2_db"
  }
  "app3-db" = {
    username = "app3_admin"
    host     = "db.prod.aws.com"
    port     = "5432"
    database = "app3_db"
  }
}
```

### Step 2: One command deploys all
```bash
terraform init
terraform plan    # Preview what will be created
terraform apply   # Create all 3 secrets with auto-generated passwords
```

### Step 3: Get the secret names to use in apps
```bash
$ terraform output secret_names
{
  "app1-db" = "app1-db-abc123xyz"
  "app2-db" = "app2-db-def456uvw"
  "app3-db" = "app3-db-ghi789rst"
}
```

### Step 4: Apps retrieve from AWS Secrets Manager
```python
# app1/config.py
import boto3
import json

client = boto3.client('secretsmanager')
secret = json.loads(
    client.get_secret_value(SecretId='app1-db-abc123xyz')['SecretString']
)

DB_USER = secret['username']      # "app1_admin"
DB_PASSWORD = secret['password']  # "xK9$mL2@pQ7vN4wR" (auto-generated)
DB_HOST = secret['host']
DB_PORT = secret['port']
DB_NAME = secret['database']
```

---

## Real Example Output

### What Gets Created in AWS Secrets Manager:

```json
Secret Name: app1-db-abc123xyz
{
  "username": "app1_admin",
  "password": "xK9$mL2@pQ7vN4wR",
  "host": "db.prod.aws.com",
  "port": "5432",
  "database": "app1_db"
}

Secret Name: app2-db-def456uvw
{
  "username": "app2_admin",
  "password": "tR3@zB8#sY5$pL1", 
  "host": "db.prod.aws.com",
  "port": "5432",
  "database": "app2_db"
}

Secret Name: app3-db-ghi789rst
{
  "username": "app3_admin",
  "password": "qW7*fD4!mK6$nP9",
  "host": "db.prod.aws.com",
  "port": "5432",
  "database": "app3_db"
}
```

Each password is **unique, 16 chars, with special characters** - auto-generated randomly.

---

## Benefits Summary

| Aspect | Manual | Terraform |
|--------|--------|-----------|
| **Time** | 30+ min per env | 2 min all envs |
| **Errors** | High (manual mistakes) | Zero (automated) |
| **Passwords** | Hardcoded/weak | Auto-generated/strong |
| **Tracking** | None | Git history + state |
| **Reproducibility** | Hard | Just run `terraform apply` |
| **Disaster Recovery** | Manual recreation | `git pull && terraform apply` |
| **Multiple Regions** | Copy-paste all | Change region var, run plan/apply |
| **Audit Trail** | None | Full git history |

---

## Bonus: Deploy to Another Region

Want the same secrets in `eu-west-1` too?

```bash
# Just create another deployment:
cd terraform/eu-west-1
cp -r ../us-east-1/* .
# Change vars.tf: aws_region = "eu-west-1"
terraform init
terraform apply
# Done! 2 minutes instead of 30 minutes manual work
```

---

## Bonus: Update a Password

Need to rotate a password?

```bash
# Modify vars.tf to remove/add secrets
# Then:
terraform plan   # Shows what will change
terraform apply  # Creates/updates/deletes secrets
```

AWS Secrets Manager handles versioning automatically.

---

## Bonus: Retrieve Secret from CLI

```bash
# Get the secret name from terraform output
SECRET_NAME=$(terraform output -raw secret_names | jq -r '.["app1-db"]')

# Retrieve the secret
aws secretsmanager get-secret-value \
  --secret-id $SECRET_NAME \
  --query SecretString | jq .
```

Output:
```json
{
  "username": "app1_admin",
  "password": "xK9$mL2@pQ7vN4wR",
  "host": "db.prod.aws.com",
  "port": "5432",
  "database": "app1_db"
}
```

---

## Real Team Scenario

**Without Terraform (Nightmare):**
- DevOps creates secrets manually
- Sends ARNs via Slack (security risk! 😱)
- Dev pastes into configs (now visible in repo!)
- Passwords expire? Manual recreation
- New team member? "How do I create secrets?" → 30 min tutorial

**With Terraform (Clean):**
- All secrets defined in Git (`.gitignore` hides secrets)
- Anyone can deploy: `terraform apply`
- Password rotation: Just merge PR with changes
- New team member: `git pull && terraform apply`
- Everything tracked in Git history

---

## The Magic Moment

Run this:
```bash
terraform apply
```

🎉 **All 3 secrets created in AWS** with:
- ✅ Unique passwords for each
- ✅ Strong 16-char passwords with special chars
- ✅ Proper JSON structure
- ✅ All metadata (usernames, hosts, ports, databases)
- ✅ Ready to use in your apps

No manual work. No copy-pasting. No human errors.

**That's the power of Terraform for secrets management!** 🚀
