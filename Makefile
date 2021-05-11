SHELL := /bin/bash

export TERRAFORM = /usr/local/bin/terraform

# List of targets the `readme` target should call before generating the readme
export README_DEPS ?= docs/targets.md docs/terraform.md

-include $(shell curl -sSL -o .build-harness "https://git.io/build-harness"; echo .build-harness)

## Lint Terraform code
lint:
	@cd examples/complete && terraform init && terraform fmt && terraform validate
	@terraform fmt
