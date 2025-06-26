resource "aws_sns_topic" "notificaciones" {
  name = "sns-notificaciones-viajes"
}

resource "aws_iam_policy" "lambda_publish_sns_policy" {
  name = "lambda-filtro-notificacion-publish-sns"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = aws_sns_topic.notificaciones.arn
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_publish_sns_attach" {
  role       = aws_iam_role.lambda_filtro_notificacion_exec_role.name
  policy_arn = aws_iam_policy.lambda_publish_sns_policy.arn
}