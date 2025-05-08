data "archive_file" "lambda_viajes" {
  type        = "zip"
  source_dir  = "${path.module}/../viajes"
  output_path = "${path.module}/bin/viajes.zip"
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
resource "aws_lambda_function" "viajes" {
  function_name    = "viajes"
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  role             = aws_iam_role.lambda_viajes_exec_role.arn // El arn es el ID para conectar el rol con el recurso
  filename         = data.archive_file.lambda_viajes.output_path
  source_code_hash = data.archive_file.lambda_viajes.output_base64sha512

}