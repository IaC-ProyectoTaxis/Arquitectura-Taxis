data "archive_file" "lambda_usuarios" {
  type        = "zip"
  source_dir  = "${path.module}/../usuarios"
  output_path = "${path.module}/bin/usuarios.zip"
}