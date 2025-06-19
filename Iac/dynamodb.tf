
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