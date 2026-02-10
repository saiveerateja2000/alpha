locals {
  secret_json = {
    for secret_name, static_fields in var.secrets :
      secret_name => jsonencode(merge(
        static_fields,
        {
          for field_name in lookup(var.random_password_fields, secret_name, []) :
            field_name => random_password.pwd["${secret_name}.${field_name}"].result
        }
      ))
  }
}
