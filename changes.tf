locals {
  ssm_changed_lambda_name         = "${var.environment}-${var.project}-ssm-changed"
  ssm_changed_lambda_zip_filename = "${path.module}/ssm_changed_notification.zip"
  cluster_name                    = split("/", var.ecs_cluster_arn)[1]
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "archive_file" "ssm_changed_notification" {
  type             = "zip"
  source_file      = "${path.module}/ssm_changed_notification.py"
  output_path      = local.ssm_changed_lambda_zip_filename
  output_file_mode = "0755"
}


resource "aws_lambda_function" "ssm_changed_notification" {
  function_name    = local.ssm_changed_lambda_name
  role             = aws_iam_role.ssm_changed_notification.arn
  filename         = local.ssm_changed_lambda_zip_filename
  handler          = "ssm_changed_notification.lambda_handler"
  source_code_hash = data.archive_file.ssm_changed_notification.output_base64sha256
  runtime          = "python3.9"
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
    aws_iam_role.ssm_changed_notification,
    aws_cloudwatch_log_group.ssm_changed_notification
  ]
}

resource "aws_cloudwatch_log_group" "ssm_changed_notification" {
  name              = "/aws/lambda/${local.ssm_changed_lambda_name}"
  retention_in_days = var.log_retention
  tags              = var.tags
}


################################################
#### IAM                                    ####
################################################

resource "aws_iam_role" "ssm_changed_notification" {
  name               = "${local.ssm_changed_lambda_name}-role"
  description        = "Role used for lambda function ${local.ssm_changed_lambda_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ssm_changed_notification.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "ssm_changed_notification" {
  name   = "${local.ssm_changed_lambda_name}-policy"
  policy = data.aws_iam_policy_document.role_ssm_changed_notification.json
  role   = aws_iam_role.ssm_changed_notification.id
}

data "aws_iam_policy_document" "assume_role_ssm_changed_notification" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "role_ssm_changed_notification" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.ssm_changed_notification.arn}*"
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
      "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task/${local.cluster_name}/*"
    ]
  }
}

resource "aws_cloudwatch_event_rule" "ssm_changed" {
  count         = var.restart_on_ssh_keys_change ? 1 : 0
  name          = local.ssm_changed_lambda_name
  event_pattern = <<PATTERN
{
  "detail-type": [
    "Parameter Store Change"
  ],
  "source": ["aws.ssm"]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "ssm_changed" {
  count     = var.restart_on_ssh_keys_change ? 1 : 0
  rule      = aws_cloudwatch_event_rule.ssm_changed[count.index].name
  target_id = "StopECSTask"
  arn       = aws_lambda_function.ssm_changed_notification.arn
}

resource "aws_lambda_permission" "target_lambda_permission" {
  count         = var.restart_on_ssh_keys_change ? 1 : 0
  action        = "lambda:InvokeFunction"
  function_name = local.ssm_changed_lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ssm_changed[count.index].arn
}
