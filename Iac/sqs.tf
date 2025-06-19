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