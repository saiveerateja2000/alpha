provider "aws" {
  region = var.aws_region
}

# KMS key for encrypting secrets
resource "aws_kms_key" "secrets" {
  description             = "KMS key for encrypting secrets in AWS Secrets Manager"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "secrets-encryption-key"
  }
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/secrets-key"
  target_key_id = aws_kms_key.secrets.key_id
}

resource "random_password" "pwd" {
  for_each = merge([
    for secret_name, field_list in var.random_password_fields : {
      for field_name in field_list :
        "${secret_name}.${field_name}" => true
    }
  ]...)

  length            = 32
  special           = true
  override_special  = "!@#$%^&*"
}

resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name                    = var.secret_names[each.key]
  recovery_window_in_days = 7
  kms_key_id              = aws_kms_key.secrets.id

  tags = {
    Name = var.secret_names[each.key]
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = local.secret_json

  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = each.value
}

output "secret_names" {
  value = { for k, v in aws_secretsmanager_secret.this : k => v.name }
}

output "secret_arns" {
  value = { for k, v in aws_secretsmanager_secret.this : k => v.arn }
}
