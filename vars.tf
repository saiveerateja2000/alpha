aws_region = "us-east-1"

# Define secrets with static values and "RANDOM" placeholders for generated passwords
# The "RANDOM" strings will be replaced with auto-generated 16-char passwords
secrets = {
  "secret1" = {
    abc_username = "abc_user"
    abc_password = "RANDOM"
    def_username = "def_user"
    def_password = "RANDOM"
    token        = "RANDOM"
  }

  "secret2" = {
    aplha_username = "alpha_user"
    alpha_password = "RANDOM"
    beta_username  = "beta_user"
    beta_password  = "RANDOM"
    omega_username = "omega_user"
    omega_password = "RANDOM"
  }

  "secret3" = {
    service_user  = "service_account"
    service_token = "RANDOM"
    api_key       = "RANDOM"
    db_password   = "RANDOM"
  }
}
