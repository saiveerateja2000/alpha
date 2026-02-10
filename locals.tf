locals {
  # Build flat map: "secret1.abc_password" => true for all random fields
  random_fields_flat = merge([
    for secret_name, field_list in var.random_password_fields : {
      for field_name in field_list :
        "${secret_name}.${field_name}" => true
    }
  ]...)

  # Merge static values with generated passwords
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
