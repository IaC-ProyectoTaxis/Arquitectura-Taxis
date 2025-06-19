resource "aws_sqs_queue" "usuarios_queue" {
  name = "usuarios-queue"
}

resource "aws_sqs_queue" "taxis_queue" {
  name = "taxis-queue"
}

resource "aws_sqs_queue" "viajes_queue" {
  name = "viajes-queue"
}