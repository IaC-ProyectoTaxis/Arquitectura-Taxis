resource "aws_sqs_queue" "usuarios_queue" {
  name = "usuarios-queue"
}

resource "aws_sqs_queue" "taxis_queue" {
  name = "taxis-queue"
}

resource "aws_sqs_queue" "viajes_queue" {
  name = "viajes-queue"
}

resource "aws_sqs_queue_policy" "usuarios_queue_policy" {
  queue_url = aws_sqs_queue.usuarios_queue.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "",
        Action = "sqs:SendMessage",
        Resource = aws_sqs_queue.usuarios_queue.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.app_events.arn
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue_policy" "taxis_queue_policy" {
  queue_url = aws_sqs_queue.taxis_queue.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "",
        Action = "sqs:SendMessage",
        Resource = aws_sqs_queue.taxis_queue.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.app_events.arn
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue_policy" "viajes_queue_policy" {
  queue_url = aws_sqs_queue.viajes_queue.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "sqs:SendMessage",
        Resource = aws_sqs_queue.viajes_queue.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.app_events.arn
          }
        }
      }
    ]
  })
}

resource "aws_lambda_event_source_mapping" "taxis_sqs_trigger" {
  event_source_arn = aws_sqs_queue.taxis_queue.arn
  function_name    = aws_lambda_function.taxis.arn
  batch_size       = 1
}

resource "aws_lambda_event_source_mapping" "viajes_sqs_trigger" {
  event_source_arn = aws_sqs_queue.viajes_queue.arn
  function_name    = aws_lambda_function.viajes.arn
  batch_size       = 1
}

resource "aws_lambda_event_source_mapping" "usuarios_sqs_trigger" {
  event_source_arn = aws_sqs_queue.usuarios_queue.arn
  function_name    = aws_lambda_function.usuarios.arn
  batch_size       = 1
}