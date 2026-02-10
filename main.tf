terraform {
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_password" "pwd" {
  for_each = var.secrets

  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name_prefix             = each.key
  recovery_window_in_days = 7
}

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
