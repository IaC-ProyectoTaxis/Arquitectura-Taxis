data "archive_file" "lambda_viajes" {
  type        = "zip"
  source_dir  = "${path.module}/../viajes"
  output_path = "${path.module}/bin/viajes.zip"
}

resource "aws_iam_role" "lambda_viajes_exec_role" { //Rol Necesario para ejecutar el recurso lambda
  name = "viajes_exec_role"
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

resource "aws_iam_role_policy" "lambda_dlq_policy" {
  name = "lambda-viajes-dlq-policy"
  role = aws_iam_role.lambda_viajes_exec_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:SendMessage"
        ],
        Resource = aws_sqs_queue.lambda_dlq.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_xray_policy" {
  name = "lambda-xray-permissions"
  role = aws_iam_role.lambda_viajes_exec_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy_viajes" {
  name = "viajes_policy"
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

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment_viajes" { //Vincula el rol con el policy para generar logs
  role       = aws_iam_role.lambda_viajes_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy_viajes.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole_viajes" { //Politica para almacenar la funcion en la vpc
    role       = aws_iam_role.lambda_viajes_exec_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_sqs_queue" "lambda_dlq" {
  name                              = "lambda-viajes-dlq"
  kms_master_key_id                 = "aws_kms_key.lambda_env_key.arn" 
  kms_data_key_reuse_period_seconds = 300            
}

resource "aws_lambda_function" "viajes" {
  function_name    = "viajes"
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_viajes_exec_role.arn // El arn es el ID para conectar el rol con el recurso
  filename         = data.archive_file.lambda_viajes.output_path
  source_code_hash = data.archive_file.lambda_viajes.output_base64sha512

  environment {
    variables = {
      DB_HOST     = "db-taxis-viajes-usuarios.cbmia0266pjz.us-east-2.rds.amazonaws.com" //endpoint
      DB_USER     = "IACgrupo7" //master username
      DB_PASSWORD = "grupo7_rds" //password
      DB_NAME     = "db-taxis-viajes-usuarios"
    }
  }

  kms_key_arn = aws_kms_key.lambda_env_key.arn
  
  tracing_config {
    mode = "Active"
  }

  vpc_config {
    subnet_ids         = [
                          data.aws_subnet.public1-us-east-2a.id, //Definir a que subnet ira la lambda
                          data.aws_subnet.public2-us-east-2b.id
                          ]
    security_group_ids = [data.aws_security_group.lambda_sg.id] //Definir el security group
  }
  
  

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq.arn
  }
}



resource "aws_kms_key" "lambda_env_key" {
  description             = "Clave KMS para cifrado de variables de entorno Lambda"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Id": "default",
    "Statement": [
      {
        "Sid": "AllowRootAccountFullAccess",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::923789128997:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      }
    ]
  }
  POLICY
}

resource "aws_lambda_permission" "allow_s3_viajes" { //Permiso para que el s3 pueda invocar el lambda
  statement_id  = "AllowS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.viajes.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}