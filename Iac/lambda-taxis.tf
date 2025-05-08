data "archive_file" "lambda_taxis" {
  type        = "zip"
  source_dir  = "${path.module}/../taxis"
  output_path = "${path.module}/bin/taxis.zip"
}

resource "aws_lambda_function" "taxis" {
  function_name    = "taxis"
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  role             = aws_iam_role.lambda_taxis_exec_role.arn // El arn es el ID para conectar el rol con el recurso
  filename         = data.archive_file.lambda_taxis.output_path
  source_code_hash = data.archive_file.lambda_taxis.output_base64sha512

}