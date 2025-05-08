data "archive_file" "lambda_usuarios" {
  type        = "zip"
  source_dir  = "${path.module}/../usuarios"
  output_path = "${path.module}/bin/usuarios.zip"
}

resource "aws_lambda_function" "usuarios" {
  function_name    = "usuarios"
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  role             = aws_iam_role.lambda_usuarios_exec_role.arn // El arn es el ID para conectar el rol con el recurso
  filename         = data.archive_file.lambda_usuarios.output_path
  source_code_hash = data.archive_file.lambda_usuarios.output_base64sha512
  
}