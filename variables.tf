variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "secrets" {
  type    = map(any)
  default = {}
}

variable "random_password_fields" {
  type    = map(list(string))
  default = {}
}

variable "secret_names" {
  description = "Custom names for secrets in AWS Secrets Manager"
  type        = map(string)
  default     = {}
}
