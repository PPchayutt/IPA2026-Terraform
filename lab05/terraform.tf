terraform {
  required_version = ">= 1.16.3"

  backend "s3" {
    bucket       = "ipa-tfstate-d4cd6c89"
    key          = "lab05/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.66.0"
    }
  }
}
