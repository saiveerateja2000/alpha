terraform {
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

# Create random password for each field marked as "RANDOM"
# Key format: "secret1.abc_password" => creates one random password
resource "random_password" "pwd" {
  for_each = merge([
    for secret_name, fields in var.secrets : {
      for field_name, field_value in fields :
        "${secret_name}.${field_name}" => true if field_value == "RANDOM"
    }
  ]...)

  length  = 16
  special = true
}

# Create AWS Secrets Manager secret for each secret
resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name_prefix             = each.key
  recovery_window_in_days = 7
}

# Store the secret values (with replaced random passwords)
resource "aws_secretsmanager_secret_version" "this" {
  for_each = local.secret_json

  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = each.value
}

output "secret_arns" {
  value = { for k, v in aws_secretsmanager_secret.this : k => v.arn }
}

output "secret_names" {
  value = { for k, v in aws_secretsmanager_secret.this : k => v.name }
}
