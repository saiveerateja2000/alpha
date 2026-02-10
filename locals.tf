locals {
  # Extract all fields that need random passwords
  # Creates a flat map like: "secret1.abc_password" => true
  fields_needing_random = merge([
    for secret_name, fields in var.secrets : {
      for field_name, field_value in fields :
        "${secret_name}.${field_name}" => field_value == "RANDOM"
    }
  ]...)

  # Count random fields for each secret for reference
  random_fields_per_secret = {
    for secret_name, fields in var.secrets :
      secret_name => [
        for field_name, field_value in fields :
          field_name if field_value == "RANDOM"
      ]
  }

  # Replace "RANDOM" placeholders with actual random password values
  secret_json = {
    for secret_name, fields in var.secrets :
      secret_name => jsonencode({
        for field_name, field_value in fields :
          field_name => (
            field_value == "RANDOM" 
              ? random_password.pwd["${secret_name}.${field_name}"].result
              : field_value
          )
      })
  }
}
