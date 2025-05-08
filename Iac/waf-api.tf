resource "aws_cognito_user_pool" "main_pool" {
  name = "usuarios-pool"

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  auto_verified_attributes = ["email"]
}