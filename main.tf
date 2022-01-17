data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "application" {
  source = "git::https://github.com/provectus/sak-incubator//meta-aws-application?ref=main"

  chart_version = var.chart_version
  repository    = var.chart_repository
  name          = var.chart_name
  chart         = var.chart_name
  namespace     = var.namespace

  iam_permissions = [
    {
      "Effect" : "Allow",
      "Action" : "ssm:GetParameter",
      "Resource" : "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.allowed_secrets_prefix}*"
    },
    {
      "Effect" : "Allow",
      "Action" : [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource" : [
        "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.allowed_secrets_prefix}*"
      ]
    }
  ]

  irsa_annotation_field = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  cluster_name          = var.cluster_name
  values = merge({
    "securityContext.runAsNonRoot"     = true
    "securityContext.fsGroup"          = 65534
    "env.AWS_REGION"                   = data.aws_region.current.name
    "env.AWS_DEFAULT_REGION"           = data.aws_region.current.name
    "env.POLLER_INTERVAL_MILLISECONDS" = var.poller_interval
  }, var.chart_values)

  argocd = var.argocd
}
