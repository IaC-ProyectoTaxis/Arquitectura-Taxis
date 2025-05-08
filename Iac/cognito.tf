resource "aws_api_gateway_authorizer" "cognito_auth" {
  name                   = "CognitoAuthorizer"
  rest_api_id            = aws_api_gateway_rest_api.api.id
  identity_source        = "method.request.header.Authorization"
  type                   = "COGNITO_USER_POOLS"
  provider_arns          = [aws_cognito_user_pool.main_pool.arn]
}
resource "aws_cognito_user_pool" "main_pool" {
  name = "usuarios-pool"

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_group" "admin_group" {
  name         = "admin"
  user_pool_id = aws_cognito_user_pool.main_pool.id
  description  = "Administradores del sistema"
  precedence   = 1
}


resource "aws_cognito_user_group" "user_group" {
  name         = "user"
  user_pool_id = aws_cognito_user_pool.main_pool.id
  description  = "Usuarios normales"
  precedence   = 2
}