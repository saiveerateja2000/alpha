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
  type    = map(string)
  default = {}
}
