provider "aws" {
  region = var.aws_region
}

resource "random_password" "pwd" {
  for_each = merge([
    for secret_name, field_list in var.random_password_fields : {
      for field_name in field_list :
        "${secret_name}.${field_name}" => true
    }
  ]...)

  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name                    = var.secret_names[each.key]
  recovery_window_in_days = 7
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
