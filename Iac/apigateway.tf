resource "aws_api_gateway_rest_api" "api" {
  name        = "api-taxis"
  description = "API para registrar datos desde el frontend"
}

resource "aws_api_gateway_resource" "registro" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "registro"
}

resource "aws_api_gateway_method" "post_registro" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.registro.id
  http_method   = "POST"
  authorization = "NONE"
}