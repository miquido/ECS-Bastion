variable "aws_region" {
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

variable "log_retention" {
  type        = number
  description = "How long should logs be retained"
  default     = 7
}

variable "public_ssh_keys" {
  type        = string
  description = "rsa.pub strings"
}

variable "vpc_id" {
  type        = string
  description = "vpc id"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ECS Cluster arn"
}
variable "security_groups" {
  type        = list(string)
  description = "Security groups"
}
variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnets ids"
}

variable "whitelist_ips" {
  type        = list(object({ description = string, cidr = string }))
  description = "List of ip addresses that will be allowed to connect on port 22"
}

variable "tags" {
  type        = map(string)
  description = "Default tags to apply on all created resources"
  default     = {}
}

variable "web_domain" {
  default     = ""
  type        = string
  description = "domain under which bastion will be available"
}

variable "route53_zone_id" {
  default     = ""
  type        = string
  description = "Route 53 Zone id for bastion entry"
}

variable "container_image" {
  default     = "miquidocompany/aws-ecs-bastion:2418063322-b667be3b"
  type        = string
  description = "docker image of bastion"
}

variable "auto_deploy_new_task_versions" {
  default     = false
  type        = bool
  description = "Set to true if there should be auto deploy of new task versions"
}

variable "ignore_changes_desired_count" {
  default     = true
  type        = bool
  description = "If yes than terraform will not try to update current desired count of the task"
}

variable "use_spot" {
  default     = true
  type        = bool
  description = "Set if task should run on Fargate SPOT"
}

variable "restart_on_ssh_keys_change" {
  default     = true
  type        = bool
  description = "Restart bastion ecs task when ssh keys are changed"
}
