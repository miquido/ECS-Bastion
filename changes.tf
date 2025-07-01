locals {
  pubkeys_changed_lambda_name         = "${var.environment}-${var.project}-pubkeys-changed"
  pubkeys_changed_lambda_zip_filename = "${path.module}/pubkeys_changed_notification.zip"
  cluster_name                        = split("/", var.ecs_cluster_arn)[1]
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "archive_file" "pubkeys_changed_notification" {
  type             = "zip"
  source_file      = "${path.module}/pubkeys_changed_notification.py"
  output_path      = local.pubkeys_changed_lambda_zip_filename
  output_file_mode = "0755"
}


resource "aws_lambda_function" "pubkeys_changed_notification" {
  function_name    = local.pubkeys_changed_lambda_name
  role             = aws_iam_role.pubkeys_changed_notification.arn
  filename         = local.pubkeys_changed_lambda_zip_filename
  handler          = "pubkeys_changed_notification.lambda_handler"
  source_code_hash = data.archive_file.pubkeys_changed_notification.output_base64sha256
  runtime          = "python3.13"
  timeout          = 6
  memory_size      = 256
  tags             = var.tags

  environment {
    variables = {
      CLUSTER      = var.ecs_cluster_arn
      SERVICE_NAME = module.ecs_alb_service_task.service_name
    }
  }
  depends_on = [
    aws_iam_role.pubkeys_changed_notification,
    aws_cloudwatch_log_group.pubkeys_changed_notification
  ]
}

resource "aws_cloudwatch_log_group" "pubkeys_changed_notification" {
  name              = "/aws/lambda/${local.pubkeys_changed_lambda_name}"
  retention_in_days = var.log_retention
  tags              = var.tags
}


################################################
#### IAM                                    ####
################################################

resource "aws_iam_role" "pubkeys_changed_notification" {
  name               = "${local.pubkeys_changed_lambda_name}-role"
  description        = "Role used for lambda function ${local.pubkeys_changed_lambda_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_pubkeys_changed_notification.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "pubkeys_changed_notification" {
  name   = "${local.pubkeys_changed_lambda_name}-policy"
  policy = data.aws_iam_policy_document.role_pubkeys_changed_notification.json
  role   = aws_iam_role.pubkeys_changed_notification.id
}

data "aws_iam_policy_document" "assume_role_pubkeys_changed_notification" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "role_pubkeys_changed_notification" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.pubkeys_changed_notification.arn}*"
    ]
  }

  statement {
    actions = [
      "ecs:ListTasks",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "ecs:StopTask"
    ]

    resources = [
      "arn:aws:ecs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:task/${local.cluster_name}/*"
    ]
  }
}

resource "aws_lambda_permission" "s3-event-allow_bucket" {
  count         = var.restart_on_ssh_keys_change ? 1 : 0
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pubkeys_changed_notification.arn
  principal     = "s3.amazonaws.com"
  source_arn    = module.bastion_pubkeys.bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = var.restart_on_ssh_keys_change ? 1 : 0
  bucket = module.bastion_pubkeys.bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.pubkeys_changed_notification.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3-event-allow_bucket]
}

