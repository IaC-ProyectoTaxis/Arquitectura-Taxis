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

resource "aws_lambda_function" "usuarios" {
  function_name    = "usuarios"
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  role             = aws_iam_role.lambda_usuarios_exec_role.arn // El arn es el ID para conectar el rol con el recurso
  filename         = data.archive_file.lambda_usuarios.output_path
  source_code_hash = data.archive_file.lambda_usuarios.output_base64sha512
  
}