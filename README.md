<!-- This file was automatically generated by the `build-harness`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->
[![Miquido][logo]](https://www.miquido.com/)

# ecs-bastion
Creates a service on ECS that has ssh open to enable tunneling.
---
## Usage

```hcl
  module "ecs-bastion" {
    source            = "git::ssh://git@gitlab.com/miquido/terraform/ecs-bastion.git?ref=tags/1.0"
    aws_region        = var.aws_region
    ecs_cluster_arn   = aws_ecs_cluster.main.arn
    environment       = var.environment
    project           = var.project
    public_ssh_keys   = <<EOT
                        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBoJKBh1ECj1RGt/fgiQz/DvLwW9NzDmR3RAhB5Rb1BM test
                        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/5jNq77nbp5FoRnK7lHHdHhCFa8jdJ8QzLF/M3b7nt0ansRwxgsMJMUAiHNdYvoR3UwmOgtUQzBasKfbML8hK/f0crSE0sh/cXvYBC+3jWN0sT3zW307w4po9KS+RJpP8mEu0vYh3Ua4+O06ePuagD5JfSNLJ8d6xi2QCY87cKENjs4ysupwN/+/VH5nWHerVrFKQ4oW/ARYHGfaL4N1npvSK9m2nnDy1uX+ti3GGys9/2GMW0wPbjrI+Z1sc252QdgxNGn/zT7lKWCn+00mAcov8wkclwTl3RQFSW2ni/3saFyBUi/9CiRvKtjLCdxks3+K2tTdHNUaAajlR7UfB marekmoscichowski@Mareks-MacBook-Pro.local
    EOT
    public_subnet_ids = module.vpc.public_subnet_ids
    route53_zone_id   = aws_route53_zone.default.id
    security_groups   = [module.vpc.vpc_default_security_group_id]
    vpc_id            = module.vpc.vpc_id
    web_domain        = "bastion.${local.app_web_domain}"
    whitelist_ips = [
      {
        description = "ip Marka",
        cidr        = "178.43.248.169/32",
      }
    ]
}
```
<!-- markdownlint-disable -->
## Makefile Targets
```text
Available targets:

  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
  lint                                Lint Terraform code

```
<!-- markdownlint-restore -->
<!-- markdownlint-disable -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs-bastion-task-definition"></a> [ecs-bastion-task-definition](#module\_ecs-bastion-task-definition) | git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=tags/0.46.2 |  |
| <a name="module_ecs_alb_service_task"></a> [ecs\_alb\_service\_task](#module\_ecs\_alb\_service\_task) | cloudposse/ecs-alb-service-task/aws |  |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role_policy.bastion_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_security_group.ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_parameter.bastion_pubkey](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_iam_policy_document.bastion_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | n/a | yes |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | docker image of bastion | `string` | `"miquidocompany/aws-ecs-bastion:300216988-7d78c44d"` | no |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | ECS Cluster arn | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_log_retention"></a> [log\_retention](#input\_log\_retention) | How long should logs be retained | `number` | `7` | no |
| <a name="input_project"></a> [project](#input\_project) | Account/Project Name | `string` | n/a | yes |
| <a name="input_public_ssh_keys"></a> [public\_ssh\_keys](#input\_public\_ssh\_keys) | rsa.pub strings | `string` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Public subnets ids | `list(string)` | n/a | yes |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Route 53 Zone id for bastion entry | `string` | `""` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Security groups | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags to apply on all created resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | vpc id | `string` | n/a | yes |
| <a name="input_web_domain"></a> [web\_domain](#input\_web\_domain) | domain under which bastion will be available | `string` | `""` | no |
| <a name="input_whitelist_ips"></a> [whitelist\_ips](#input\_whitelist\_ips) | List of ip addresses that will be allowed to connect on port 22 | `list(object({ description = string, cidr = string }))` | n/a | yes |

## Outputs

No outputs.
<!-- markdownlint-restore -->


## Developing

1. Make changes in terraform files

2. Regenerate documentation

    ```bash
    bash <(git archive --remote=git@gitlab.com:miquido/terraform/terraform-readme-update.git master update.sh | tar -xO)
    ```

3. Run lint

    ```
    make lint
    ```

## Copyright

Copyright © 2017-2021 [Miquido](https://miquido.com)



### Contributors

|  [![Marek Mościchowski][marekmoscichowski_avatar]][marekmoscichowski_homepage]<br/>[Marek Mościchowski][marekmoscichowski_homepage] |
|---|

  [marekmoscichowski_homepage]: https://github.com/marekmoscichowski
  [marekmoscichowski_avatar]: https://github.com/marekmoscichowski.png?size=150



  [logo]: https://www.miquido.com/img/logos/logo__miquido.svg
  [website]: https://www.miquido.com/
  [gitlab]: https://gitlab.com/miquido
  [github]: https://github.com/miquido
  [bitbucket]: https://bitbucket.org/miquido

