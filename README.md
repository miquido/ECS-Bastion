# ecs-bastion <a href="https://miquido.com"><img align="right" src="https://cdn.miquido.dev/miquido-logo.png" width="150" /></a>

Creates a service on ECS that has ssh open to enable tunneling.

## Development

```bash
make init   # run once after cloning
make readme # regenerate README.md
make lint   # lint terraform code
```

## Usage

```hcl
module "ecs-bastion" {
  source            = "git::ssh://git@gitlab.com/miquido/terraform/ecs-bastion.git?ref=1.1.23"
  aws_region        = var.aws_region
  ecs_cluster_arn   = aws_ecs_cluster.main.arn
  environment       = var.environment
  project           = var.project
  public_ssh_keys   = <<EOT
                      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBoJKBh1ECj1RGt/fgiQz/DvLwW9NzDmR3RAhB5Rb1BM test
  EOT
  public_subnet_ids = module.vpc.public_subnet_ids
  route53_zone_id   = aws_route53_zone.default.id
  security_groups   = [module.vpc.vpc_default_security_group_id]
  vpc_id            = module.vpc.vpc_id
  web_domain        = "bastion.${local.app_web_domain}"
  whitelist_ips = [
    {
      description = "office",
      cidr        = "1.2.3.4/32",
    }
  ]
  tags = var.tags
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_bastion_pubkeys"></a> [bastion\_pubkeys](#module\_bastion\_pubkeys) | cloudposse/s3-bucket/aws | 4.7.0 |
| <a name="module_ecs-bastion-task-definition"></a> [ecs-bastion-task-definition](#module\_ecs-bastion-task-definition) | git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git | 0.61.1 |
| <a name="module_ecs_alb_service_task"></a> [ecs\_alb\_service\_task](#module\_ecs\_alb\_service\_task) | git::https://github.com/cloudposse/terraform-aws-ecs-alb-service-task.git | v0.76.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.pubkeys_changed_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.pubkeys_changed_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.bastion_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.pubkeys_changed_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.pubkeys_changed_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.s3-event-allow_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket_notification.bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_object.object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_security_group.ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_auto_deploy_new_task_versions"></a> [auto\_deploy\_new\_task\_versions](#input\_auto\_deploy\_new\_task\_versions) | Set to true if there should be auto deploy of new task versions | `bool` | `false` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | n/a | yes |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | docker image of bastion | `string` | `"ghcr.io/miquido/aws-ecs-bastion:200300-f9fbf95e"` | no |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | ECS Cluster arn | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_ignore_changes_desired_count"></a> [ignore\_changes\_desired\_count](#input\_ignore\_changes\_desired\_count) | If yes than terraform will not try to update current desired count of the task | `bool` | `true` | no |
| <a name="input_log_retention"></a> [log\_retention](#input\_log\_retention) | How long should logs be retained | `number` | `7` | no |
| <a name="input_project"></a> [project](#input\_project) | Account/Project Name | `string` | n/a | yes |
| <a name="input_public_ssh_keys"></a> [public\_ssh\_keys](#input\_public\_ssh\_keys) | rsa.pub strings | `string` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Public subnets ids | `list(string)` | n/a | yes |
| <a name="input_restart_on_ssh_keys_change"></a> [restart\_on\_ssh\_keys\_change](#input\_restart\_on\_ssh\_keys\_change) | Restart bastion ecs task when ssh keys are changed | `bool` | `true` | no |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Route 53 Zone id for bastion entry | `string` | `""` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Security groups | `list(string)` | n/a | yes |
| <a name="input_service_connect_namespace"></a> [service\_connect\_namespace](#input\_service\_connect\_namespace) | aws\_service\_discovery\_private\_dns\_namespace.map.name | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags to apply on all created resources | `map(string)` | `{}` | no |
| <a name="input_use_spot"></a> [use\_spot](#input\_use\_spot) | Set if task should run on Fargate SPOT | `bool` | `true` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | vpc id | `string` | n/a | yes |
| <a name="input_web_domain"></a> [web\_domain](#input\_web\_domain) | domain under which bastion will be available | `string` | `""` | no |
| <a name="input_whitelist_ips"></a> [whitelist\_ips](#input\_whitelist\_ips) | List of ip addresses that will be allowed to connect on port 22 | `list(object({ description = string, cidr = string }))` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## License

[MIT](LICENSE)
