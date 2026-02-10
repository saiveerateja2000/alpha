aws_region = "us-east-1"

secrets = {
  "secret/alpha" = {
    abc_username = "abc_user"
    def_username = "def_user"
  }

  "secret/beta" = {
    aplha_username = "alpha_user"
    beta_username  = "beta_user"
    omega_username = "omega_user"
  }

  "secret/omega" = {
    service_user = "service_account"
  }
}

random_password_fields = {
  "secret/alpha" = ["abc_password", "def_password", "token"]
  "secret/beta" = ["alpha_password", "beta_password", "omega_password"]
  "secret/omega" = ["service_token", "api_key", "db_password"]
}
