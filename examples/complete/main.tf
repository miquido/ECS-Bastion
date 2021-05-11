provider "aws" {
  region = "us-east-1"
}

module "test" {
  source = "../../"
}
