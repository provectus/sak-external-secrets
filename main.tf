data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "local_file" "values" {
  content = templatefile("${path.module}/helm-app-template/${local.app_name}.yaml",
    {
      chart_values               = local.chart_values
      chart_repo                 = var.chart_repository
      chart_version              = var.chart_version
      module_name                = local.module_name
      app_name                   = local.app_name
      app_namespace              = var.namespace
      argo_namespace             = var.argocd.namespace
      chart_parameters           = var.chart_parameters
      chart_parameters_as_string = var.chart_parameters_as_string
  })
  file_permission      = "0644"
  directory_permission = "0755"
  filename             = "${path.root}/${var.argocd.path}/${local.app_name}.yaml"
}

locals {
  module_name  = basename(abspath(path.module))
  app_name     = "external-secrets"
  cluster_name = var.cluster_name
  aws_region   = var.aws_region == "" ? data.aws_region.current.name : var.aws_region

  aws_assume_role_arn       = module.iam_assumable_role[0].this_iam_role_arn
  template_helm_values = templatefile("${path.module}/values/values.yaml",
    {
      aws_assume_role_arn = local.aws_assume_role_arn
      poller_interval     = var.poller_interval
      aws_region          = local.aws_region
      app_name            = local.app_name
  })
  chart_values = var.chart_values == "" ? local.template_helm_values : var.chart_values
}
module "iam_assumable_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v3.6.0"
  count                         = 1
  create_role                   = true
  role_name                     = "${local.cluster_name}_external-secrets"
  provider_url                  = replace(var.cluster_oidc_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.this[0].arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:external-secrets"] //TODO dynamically get service account name and set it here. Currently all service accounts in kube-system will be able to assume this role
  tags                          = var.tags
}

resource "aws_iam_policy" "this" {
  count  = 1
  name   = "${local.cluster_name}_external-secrets-full-access"
  policy = <<-EOT
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "SecretsAccess",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:ListSecretVersionIds",
                "secretsmanager:GetSecretValue",
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${local.cluster_name}*"
        }

    ]
}
EOT
}
