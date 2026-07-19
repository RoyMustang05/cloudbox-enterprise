# =========================================================
# LABORATORIO 9 - PARTE 1
# Amazon SQS: cola principal + Dead Letter Queue
# =========================================================

resource "aws_sqs_queue" "documents_dlq" {
  name = "documents-dlq"
}

resource "aws_sqs_queue" "documents_queue" {
  name                       = "documents-queue"
  visibility_timeout_seconds = 30

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.documents_dlq.arn
    maxReceiveCount     = 3
  })
}

# =========================================================
# LABORATORIO 9 - PARTE 2
# Permisos IAM para que la Lambda Productora (createFile)
# pueda enviar mensajes a la cola
# =========================================================

resource "aws_iam_role_policy" "producer_sqs_policy" {
  name = "producer-sqs-policy"
  role = module.iam.lambda_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = aws_sqs_queue.documents_queue.arn
      }
    ]
  })
}

# =========================================================
# LABORATORIO 9 - PARTE 3
# Permisos IAM para la Lambda Consumidora
# (leer/eliminar mensajes de SQS y escribir en DynamoDB)
# =========================================================

resource "aws_iam_role_policy" "consumer_sqs_policy" {
  name = "consumer-sqs-policy"
  role = module.iam.lambda_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.documents_queue.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "consumer_dynamodb_policy" {
  name = "consumer-dynamodb-policy"
  role = module.iam.lambda_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"]
        Resource = module.dynamodb.table_arn
      }
    ]
  })
}
