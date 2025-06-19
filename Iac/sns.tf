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