# How to Customize for Your Needs

## Quick Pattern

In **vars.tf**, use this structure:

```hcl
secrets = {
  "secret-name" = {
    static_key_1 = "static_value"
    static_key_2 = "another_value"
    password_key = "RANDOM"      # This will be auto-generated
    token_key    = "RANDOM"      # This will be auto-generated
  }
}
```

**Replace "RANDOM" with any key that needs an auto-generated password.**

---

## Examples

### Example 1: User + Password
```hcl
secrets = {
  "db-creds" = {
    username = "admin"
    password = "RANDOM"
  }
}
```
**Result in AWS:**
```json
{
  "username": "admin",
  "password": "xK9$mL2@pQ7vN4wR"
}
```

### Example 2: Multiple Credentials (Your Case)
```hcl
secrets = {
  "secret1" = {
    abc_username = "abc_user"
    abc_password = "RANDOM"
    def_username = "def_user"
    def_password = "RANDOM"
    token        = "RANDOM"
  }
}
```
**Result in AWS:**
```json
{
  "abc_username": "abc_user",
  "abc_password": "kJ7$mP2@xL9nQ4vR",
  "def_username": "def_user",
  "def_password": "tR3@zB8#sY5$pL1",
  "token": "qW7*fD4!mK6$nP9"
}
```

### Example 3: Database + API Credentials
```hcl
secrets = {
  "app-secrets" = {
    db_host      = "prod-db.rds.com"
    db_user      = "dbadmin"
    db_password  = "RANDOM"
    db_port      = "5432"
    api_key      = "RANDOM"
    api_secret   = "RANDOM"
  }
}
```
**Result in AWS:**
```json
{
  "db_host": "prod-db.rds.com",
  "db_user": "dbadmin",
  "db_password": "xK9$mL2@pQ7vN4wR",
  "db_port": "5432",
  "api_key": "kJ7$mP2@xL9nQ4vR",
  "api_secret": "tR3@zB8#sY5$pL1"
}
```

---

## How It Works (Behind the Scenes)

1. **vars.tf** → You define secrets with static values and "RANDOM" placeholders
2. **main.tf** → Creates random_password for every field with "RANDOM"
   - Example: `random_password.pwd["secret1.token"]`
3. **locals.tf** → Replaces "RANDOM" strings with actual generated values
4. **AWS** → Stores final JSON with real passwords

---

## Add More Secrets

Just add to vars.tf:

```hcl
secrets = {
  "secret1" = { ... }
  "secret2" = { ... }
  "secret3" = { ... }    # Add this
  "secret4" = { ... }    # Add this
}
terraform apply  # All created!
```

---

## Deploy

```bash
# See what will be created
terraform plan

# Create all secrets
terraform apply

# Get secret names
terraform output secret_names
```

---

## That's It!

The code automatically handles:
- ✅ Generating random passwords for RANDOM fields
- ✅ Keeping static values as-is
- ✅ Creating proper JSON for AWS
- ✅ Works for any number of secrets
- ✅ Works for any number of fields per secret
