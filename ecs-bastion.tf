module "ecs-bastion-task-definition" {
  source = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=0.58.1"

  container_image  = var.container_image
  container_name   = "bastion"
  container_memory = 256

  log_configuration = {
    logDriver     = "awslogs"
    secretOptions = null
    options = {
      awslogs-region        = var.aws_region
      awslogs-group         = aws_cloudwatch_log_group.app.id
      awslogs-stream-prefix = "bastion"
    }
  }
  environment = [
    {
      name  = "BASTION_URL"
      value = var.web_domain
    },
    {
      name  = "HOSTED_ZONE_ID"
      value = var.route53_zone_id
    },
    {
      name  = "KEYS_BUCKET"
      value = module.bastion_pubkeys.bucket_id
    }
  ]

}

locals {
  container_definitions      = compact([module.ecs-bastion-task-definition.json_map_encoded])
  container_definitions_json = "[${join(",", local.container_definitions)}]"
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/ecs/${var.project}-${var.environment}-bastion"
  tags              = var.tags
  retention_in_days = var.log_retention
}

resource "aws_iam_role_policy" "bastion_policy" {
  name = "${var.project}-${var.environment}-bastion_policy"
  role = module.ecs_alb_service_task.task_role_name

  policy = data.aws_iam_policy_document.bastion_policy.json
}

data "aws_iam_policy_document" "bastion_policy" {
  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
    ]
    resources = ["arn:aws:route53:::hostedzone/${var.route53_zone_id}"]
  }

  statement {
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${module.bastion_pubkeys.bucket_arn}*",
    ]
  }
}

module "bastion_pubkeys" {
  source  = "cloudposse/s3-bucket/aws"
  version = "2.0.1"

  acl                          = "private"
  enabled                      = true
  versioning_enabled           = false
  name                         = "bastion-keys"
  stage                        = var.environment
  namespace                    = var.project
  allow_encrypted_uploads_only = false
  sse_algorithm                = "AES256"
}

resource "aws_s3_object" "object" {
  bucket                 = module.bastion_pubkeys.bucket_id
  key                    = "keys.txt"
  content                = var.public_ssh_keys
  server_side_encryption = "AES256"
}


resource "aws_security_group" "ssh" {
  name        = "${var.project}-${var.environment}-bastion-ssh-whitelist"
  description = "Allow ips to ssh into bastion host"
  vpc_id      = var.vpc_id
  dynamic "ingress" {
    for_each = var.whitelist_ips
    content {
      description = ingress.value.description
      from_port   = 22
      protocol    = "tcp"
      to_port     = 22
      cidr_blocks = [ingress.value.cidr]
    }
  }
  tags = merge({ "Name" : "ECS Bastion SSH whitelist" }, var.tags)
}

module "ecs_alb_service_task" {
  source                         = "git::https://github.com/cloudposse/terraform-aws-ecs-alb-service-task.git?ref=0.71.0"
  namespace                      = var.project
  stage                          = var.environment
  name                           = "bastion"
  container_definition_json      = local.container_definitions_json
  ecs_cluster_arn                = var.ecs_cluster_arn
  launch_type                    = "FARGATE"
  vpc_id                         = var.vpc_id
  security_group_ids             = concat(var.security_groups, [aws_security_group.ssh.id])
  subnet_ids                     = var.public_subnet_ids
  tags                           = var.tags
  ignore_changes_task_definition = var.auto_deploy_new_task_versions == true ? false : true
  force_new_deployment           = var.auto_deploy_new_task_versions == true ? true : false
  network_mode                   = "awsvpc"
  assign_public_ip               = true
  propagate_tags                 = "SERVICE"
  desired_count                  = 1
  ignore_changes_desired_count   = var.ignore_changes_desired_count
  task_memory                    = 512
  task_cpu                       = 256
  exec_enabled                   = true

  capacity_provider_strategies = [
    {
      capacity_provider = "FARGATE"
      weight            = var.use_spot == false ? 1 : 0
      base              = null
    },
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = var.use_spot == true ? 1 : 0
      base              = null
    }
  ]

  runtime_platform = [
    {
      operating_system_family = "LINUX"
      cpu_architecture        = var.use_spot == true ? "X86_64" : "ARM64"
    }
  ]
}
