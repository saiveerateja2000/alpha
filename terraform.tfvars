aws_region = "us-east-1"

secrets = {
  "secret1" = {
    abc_username = "abc_user"
    def_username = "def_user"
  }

  "secret2" = {
    aplha_username = "alpha_user"
    beta_username  = "beta_user"
    omega_username = "omega_user"
  }

  "secret3" = {
    service_user = "service_account"
  }
}

random_password_fields = {
  "secret1" = ["abc_password", "def_password", "token"]
  "secret2" = ["alpha_password", "beta_password", "omega_password"]
  "secret3" = ["service_token", "api_key", "db_password"]
}

secret_names = {
  "secret1" = "app-db-credentials"
  "secret2" = "api-service-credentials"
  "secret3" = "backend-service-credentials"
  "secret4" = "dummy"
}
