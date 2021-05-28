provider "aws" {
  region = "us-east-1"
}

module "test" {
  source = "../../"

  aws_region      = "eu-central-1"
  ecs_cluster_arn = "arn::::ecs"
  environment     = "test"
  project         = "tets"
  public_ssh_keys = <<EOT
                        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFNEFX29jEQXgiBJnAukOAHW34fqRUnyJixMosdN9RZN krzysztof.kluska@miquido.com
                        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTeTFlxDL2Oskr9b0C5nN3gesROqhdQa4rjfNLgSWIO11q9MqIDcqyRJISIUdA0xMH2Tj7mDjVIccNKmFmd2E5bcNhFfCEhFWwcnJl7mrpXeRYGh1ASU55WaDKmuDbvQOwt1geF6fThwR1OE9dMLyYH7bNjLot3fWokfhOnR7q3dIb5NxjQQQ7jgOb4AGhgYSC+OgOtyQkKNzFRc4RxKSaBzd5pUyuA0POVHZTVnEFkw8bgEMzPNgLyT5Qhmt+Af8eoFmT3OxJ0efvmcw0jL0jd7gUH6PLwP3GOXi4FD+K7OHWUoEkcs31XO2T3OXLC8kVCr/7t9rGYsJOu/fKPDkx wiktor.urbanczyk@miquido.com
    EOT

  public_subnet_ids = ["fake1", "fake2"]
  route53_zone_id   = "zone-id"
  security_groups   = ["sg1"]
  vpc_id            = "vpc1"
  web_domain        = "bastion.dev.example.com"

  whitelist_ips = [
    {
      description = "All",
      cidr        = "0.0.0.0/0",
    },
  ]
}
