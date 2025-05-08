data "archive_file" "lambda_viajes" {
  type        = "zip"
  source_dir  = "${path.module}/../viajes"
  output_path = "${path.module}/bin/viajes.zip"
}