locals {
  functions = ["createFile", "getFiles", "getFileById", "updateFile", "deleteFile"]
}

# Instala las dependencias de cada Lambda (node_modules) antes de empaquetar.
resource "null_resource" "npm_install" {
  for_each = toset(local.functions)

  triggers = {
    package_json = filesha1("${path.root}/../backend/${each.value}/package.json")
  }

  provisioner "local-exec" {
    command     = "npm install --omit=dev"
    working_dir = "${path.root}/../backend/${each.value}"
  }
}

data "archive_file" "zips" {
  for_each    = toset(local.functions)
  type        = "zip"
  source_dir  = "${path.root}/../backend/${each.value}"
  output_path = "${path.root}/../backend/${each.value}.zip"

  depends_on = [null_resource.npm_install]
}

resource "aws_lambda_function" "functions" {
  for_each         = toset(local.functions)
  function_name    = each.value
  filename         = data.archive_file.zips[each.value].output_path
  source_code_hash = data.archive_file.zips[each.value].output_base64sha256
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  role             = var.lambda_role_arn
  timeout          = 10

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
      # QUEUE_URL solo lo usa createFile (Lambda Productora). Al resto no le afecta.
      QUEUE_URL = var.queue_url
    }
  }
}
