data "archive_file" "lambda_usuarios" {
  type        = "zip"
  source_dir  = "${path.module}/../usuarios"
  output_path = "${path.module}/bin/usuarios.zip"
}

resource "aws_iam_role" "lambda_usuarios_exec_role" { //Rol Necesario para ejecutar el recurso lambda
  name = "usuarios_exec_role"
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

resource "aws_iam_policy" "lambda_policy_usuarios" {
  name = "usuarios_policy"
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

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment_usuarios" { //Vincula el rol con el policy para generar logs
  role       = aws_iam_role.lambda_usuarios_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy_usuarios.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole_usuarios" { //Politica para almacenar la funcion en la vpc
    role       = aws_iam_role.lambda_usuarios_exec_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "usuarios" {
  function_name    = "usuarios"
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_usuarios_exec_role.arn // El arn es el ID para conectar el rol con el recurso
  filename         = data.archive_file.lambda_usuarios.output_path
  source_code_hash = data.archive_file.lambda_usuarios.output_base64sha512


  kms_key_arn = aws_kms_key.lambda_usuarios_key.arn
 
  
  //dead_letter_config {
  //  target_arn = "test"
  // }

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
  
}




resource "aws_kms_key" "lambda_usuarios_key" {
  description          = "Clave kms para cifrar variables de entorno de la Lambda Usuarios"
  is_enabled           = true
  enable_key_rotation  = true

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "lambda-usuarios-kms-key-policy",
    Statement = [
      {
        Sid: "AllowRootAccountFullAccess",
        Effect: "Allow",
        Principal: {
          AWS: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action: "kms:*",
        Resource: "*"
      }
    ]
  })
}

resource "aws_lambda_permission" "allow_s3_usuarios" { //Permiso para que el s3 pueda invocar el lambda
  statement_id  = "AllowS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.usuarios.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}