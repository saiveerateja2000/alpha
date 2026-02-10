# AWS Secrets Manager with Terraform

Minimal Terraform setup for creating secrets in AWS Secrets Manager with auto-generated passwords.

## Quick Start

```bash
terraform init
terraform plan
terraform apply
```

## Structure

- **terraform.tfvars** - Define your secrets here
- **variables.tf** - Variable types
- **locals.tf** - Data transformation
- **main.tf** - AWS resources & outputs
- **versions.tf** - Provider configuration

## Usage

Edit `terraform.tfvars` to add/modify secrets:

```hcl
secrets = {
  "secret1" = { username = "user1", host = "host1" }
}

random_password_fields = {
  "secret1" = ["password", "api_key"]
}

secret_names = {
  "secret1" = "my-secret-name"
}
```

Then run:
```bash
terraform plan
terraform apply
```

## Adding New Secrets

Just add 3 entries to `terraform.tfvars`:

1. In `secrets` block
2. In `random_password_fields` block
3. In `secret_names` block

Then: `terraform apply`

## Outputs

- `secret_names` - Names of created secrets
- `secret_arns` - ARNs of created secrets
