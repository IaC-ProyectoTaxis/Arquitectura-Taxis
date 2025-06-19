resource "aws_sns_topic" "app_events" {
  name = "app-events-topic"
}

resource "aws_sns_topic_subscription" "usuarios_sub" {
  topic_arn = aws_sns_topic.app_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.usuarios_queue.arn
}

resource "aws_sns_topic_subscription" "taxis_sub" {
  topic_arn = aws_sns_topic.app_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.taxis_queue.arn
}

resource "aws_sns_topic_subscription" "viajes_sub" {
  topic_arn = aws_sns_topic.app_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.viajes_queue.arn
}

resource "aws_iam_policy" "lambda_publish_sns" {
  name = "lambda-publish-to-sns"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["sns:Publish"],
        Resource = aws_sns_topic.app_events.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "usuarios_publish_sns_attach" {
  role       = aws_iam_role.lambda_usuarios_exec_role.name
  policy_arn = aws_iam_policy.lambda_publish_sns.arn
}