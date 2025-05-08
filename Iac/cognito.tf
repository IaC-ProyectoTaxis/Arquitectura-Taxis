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