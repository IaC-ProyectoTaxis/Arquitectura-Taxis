
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