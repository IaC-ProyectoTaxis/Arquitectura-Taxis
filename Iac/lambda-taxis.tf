data "archive_file" "lambda_taxis" {
  type        = "zip"
  source_dir  = "${path.module}/../taxis"
  output_path = "${path.module}/bin/taxis.zip"
}

resource "aws_iam_role" "lambda_taxis_exec_role" { //Rol Necesario para ejecutar el recurso lambda
  name = "taxis_exec_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "taxis_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" { //Vincula el rol con el policy para generar logs
  role       = aws_iam_role.lambda_taxis_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" { //Politica para almacenar la funcion en la vpc
    role       = aws_iam_role.lambda_taxis_exec_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "taxis" {
  function_name    = "taxis"
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_taxis_exec_role.arn // El arn es el ID para conectar el rol con el recurso
  filename         = data.archive_file.lambda_taxis.output_path
  source_code_hash = data.archive_file.lambda_taxis.output_base64sha512
 

  

  kms_key_arn = aws_kms_key.lambda_taxis_key.arn
  
  // dead_letter_config {
  //  target_arn = "test"
  // } 

  tracing_config {
    mode = "Active"
  }

  vpc_config {
    subnet_ids         = [
                          aws_subnet.public1-us-east-2a.id, //Solo 2 subnets                          aws_subnet.public2-us-east-2b.id
                          ]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
  
}

resource "aws_iam_policy" "lambda_taxis_sqs_policy" {
  name = "lambda-taxis-sqs-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = aws_sqs_queue.taxis_queue.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_taxis_sqs_attach" {
  role       = aws_iam_role.lambda_taxis_exec_role.name
  policy_arn = aws_iam_policy.lambda_taxis_sqs_policy.arn
}




resource "aws_kms_key" "lambda_taxis_key" {
  description          = "Clave kms para cifrar variables de entorno de la Lambda Taxis"
  is_enabled           = true
  enable_key_rotation  = true

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "lambda-kms-key-default-policy",
    Statement = [
      {
        Sid      = "Enable IAM User Permissions",
        Effect   = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}



resource "aws_lambda_permission" "allow_s3" { //Permiso para que el s3 pueda invocar el lambda
  statement_id  = "AllowS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.taxis.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}