locals {
  secret_json = {
    for name, data in var.secrets :
      name => jsonencode(merge(data, {
        password = random_password.pwd[name].result
      }))
  }
}
