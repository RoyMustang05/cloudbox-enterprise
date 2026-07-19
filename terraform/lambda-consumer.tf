# =========================================================
# LABORATORIO 9 - PARTE 3
# Lambda Consumidora: procesa los mensajes de documents-queue
# y los guarda en DynamoDB (Files)
# =========================================================

resource "null_resource" "consumer_npm_install" {
  triggers = {
    package_json = filesha1("${path.root}/../backend/consumer/package.json")
  }

  provisioner "local-exec" {
    command     = "npm install --omit=dev"
    working_dir = "${path.root}/../backend/consumer"
  }
}

data "archive_file" "consumer_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../backend/consumer"
  output_path = "${path.root}/../backend/consumer.zip"

  depends_on = [null_resource.consumer_npm_install]
}

resource "aws_lambda_function" "consumer" {
  function_name    = "documents-consumer"
  filename         = data.archive_file.consumer_zip.output_path
  source_code_hash = data.archive_file.consumer_zip.output_base64sha256
  role             = module.iam.lambda_role_arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 10

  environment {
    variables = {
      TABLE_NAME = module.dynamodb.table_name
    }
  }
}

# Conecta la cola SQS con la Lambda Consumidora: AWS invocará
# automáticamente la función cuando exista un mensaje disponible.
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.documents_queue.arn
  function_name    = aws_lambda_function.consumer.arn
  batch_size       = 1
}
