SHELL := /bin/bash

.PHONY: init lint readme

## Initialize local dev environment (run once after cloning)
init:
	pre-commit install
	@echo "pre-commit hooks installed"

## Generate README.md from terraform-docs
readme:
	terraform-docs .

## Lint terraform code
lint:
	terraform fmt -check -recursive
	terraform validate