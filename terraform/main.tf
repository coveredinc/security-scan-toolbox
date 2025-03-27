provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  expected_repository_name = "${local.environment}-security-scan-toolbox"
  actual_repository_name   = module.ecr_repository.repository_name
  actual_repository_arn    = module.ecr_repository.repository_arn
  environment              = terraform.workspace
  common_tags = merge(var.additional_tags,
    {
      ApplicationName = "security-scan-toolbox"
      BusinessUnit    = ""
      CodeSource      = "https://github.com/coveredinc/security-scan-toolbox"
      Confidentiality = "none"
      DRCategory      = "category-4"
      Environment     = local.environment
      Owner           = "Security"
      STRIDE-SYS      = "N/A"
  })
}

module "ecr_repository" {
  source = "git@github.com:coveredinc/tf-ecr-repository.git?ref=v2.1.0"

  application_name = "security-scan-toolbox"
  environment      = local.environment
  lifecycle_policy = var.lifecycle_policy
}
# Test Output
output "expected_repository_arn" {
  value = local.actual_repository_arn != "" ? upper(true) : "FALSE. Got ${local.actual_repository_arn}"
}

output "expected_repository_name" {
  value = local.expected_repository_name == local.actual_repository_name ? upper(true) : "FALSE. Expected: ${local.expected_repository_name} Actual: ${local.actual_repository_name}"
}