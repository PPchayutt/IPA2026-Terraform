module "web_server" {
  source = "./modules/web-server"

  name_prefix   = local.name_prefix
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnets[0]
  root_volume   = local.effective_root_volume
  tags          = local.common_tags
  servers       = local.effective_servers
  ingress_rules = local.ingress_rules
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name_prefix}-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
}

import {
  to = aws_dynamodb_table.adopted
  id = "ipa-adopted-12582"
}

resource "aws_dynamodb_table" "adopted" {
  name         = "ipa-adopted-12582"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
