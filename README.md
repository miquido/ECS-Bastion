# ecs-bastion <a href="https://miquido.com"><img align="right" src="https://cdn.miquido.dev/miquido-logo.png" width="150" /></a>

Creates a service on ECS that has ssh open to enable tunneling.

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
<!-- END_TF_DOCS -->

## License

[MIT](LICENSE)
