
resource "aws_dynamodb_table" "usuarios" {
  name         = "usuarios"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = "prod"
  }
}

resource "aws_dynamodb_table" "taxis" {
  name         = "taxis"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "placa"

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "placa"
    type = "S"
  }

  tags = {
    Environment = "prod"
  }
}

resource "aws_dynamodb_table" "viajes" {
  name         = "viajes"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = "prod"
  }
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name = "lambda-dynamodb-access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        Resource = [
          aws_dynamodb_table.usuarios.arn,
          aws_dynamodb_table.taxis.arn,
          aws_dynamodb_table.viajes.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "usuarios_dynamodb_attach" {
  role       = aws_iam_role.lambda_usuarios_exec_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

resource "aws_iam_role_policy_attachment" "taxis_dynamodb_attach" {
  role       = aws_iam_role.lambda_taxis_exec_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

resource "aws_iam_role_policy_attachment" "viajes_dynamodb_attach" {
  role       = aws_iam_role.lambda_viajes_exec_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

resource "aws_lambda_event_source_mapping" "viajes_stream_to_lambda" {
  event_source_arn  = aws_dynamodb_table.viajes.stream_arn
  function_name     = aws_lambda_function.filtro_notificacion.arn
  starting_position = "LATEST"
  batch_size        = 1
  enabled           = true
}


resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_subnet.public1-us-east-2a.vpc_id
  service_name      = "com.amazonaws.us-east-2.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [
    aws_route_table.public.id
  ]

  tags = {
    Name = "dynamodb-endpoint"
  }
}