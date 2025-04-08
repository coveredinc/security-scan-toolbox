provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

terraform {
  backend "s3" {
    bucket  = "stride-terraform"
    key     = "env-shards/security-scan-toolbox/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
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

module "cci-oidc-role" {
  source           = "git@github.com:coveredinc/tf-oidc-role?ref=v1.0.0"
  application_name = "security-scan-toolbox"
  environment      = local.environment
  github_repo_name = "security-scan-toolbox"
  role_path        = "/security/"
}

data "aws_iam_policy_document" "oidc_policy" {
  statement {
    sid       = "ECRActions"
    effect    = "Allow"
    actions   = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:CreateRepository"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cci_role_oidc_policy" {
  role   = module.cci-oidc-role.role_name
  policy = data.aws_iam_policy_document.oidc_policy.json
  name   = "security-scan-toolbox-oidc-policy"
}

#OUTPUTS
output "oidc_role_arn" {
  value = module.cci-oidc-role.role_arn
}

output "expected_repository_arn" {
  value = local.actual_repository_arn != "" ? upper(true) : "FALSE. Got ${local.actual_repository_arn}"
}

output "expected_repository_name" {
  value = local.expected_repository_name == local.actual_repository_name ? upper(true) : "FALSE. Expected: ${local.expected_repository_name} Actual: ${local.actual_repository_name}"
}