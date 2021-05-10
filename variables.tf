variable "aws_region" {
  type = string
}

variable "web_domain" {
  type = string
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project" {
  type        = string
  description = "Account/Project Name"
}

variable "route53_zone_id" {
  type        = string
  description = "Route 53 Zone id for bastion entry"
}

variable "log_retention" {
  type        = number
  description = "How long should logs be retained"
  default     = 7
}

variable "public_ssh_keys" {
  type = string
  description = "rsa.pub strings"
}

variable "vpc_id" {
  type = string
  description = "vpc id"
}

variable "ecs_cluster_arn" {
  type = string
  description = "ECS Cluster arn"
}
variable "security_groups" {
  type = list(string)
  description = "Security groups"
}
variable "public_subnet_ids" {
  type = list(string)
  description = "Public subnets ids"
}

variable "whitelist_ips" {
  type = list(object({description = string, cidr = string}))
}

variable "tags" {
  type        = map(string)
  description = "Default tags to apply on all created resources"
  default     = {}
}
