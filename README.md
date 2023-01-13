# External Secrets

__warning:__ this module only works with ArgoCD on AWS and is based on <https://github.com/external-secrets/external-secrets>

## Description

1. You could add this module to your yaml:

``` hcl
module external_secrets {
  source         = "github.com/provectus/sak-external-secrets"
  argocd         = module.argocd.state
  cluster_name   = module.eks.cluster_id
  cluster_oidc_url  = module.kubernetes.cluster_oidc_url
}
```

This apply does:

- generates ArgoCd chart, you need to apply
- generates iam role and policy:
```"Resource": "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${local.cluster_name}*"```
you need set this in below in example section ```${local.cluster_name}```

2.In kubernetes ```kubectl apply -f external_secret_example.yaml```
Please change ${local.cluster_name} to your name

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: secretstore-sample
  namespace: kube-system
spec:
  provider:
    aws:
      service: SecretsManager
      region: eu-north-1
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${local.cluster_name}
  namespace: kube-system
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: secretstore-sample
    kind: SecretStore
  target:
    name: test-secrets
    creationPolicy: Owner
  data:
  - secretKey: cleanspeak_admin_pass
    remoteRef:
      key: ${local.cluster_name}
```

3. In AWS SecretManager create a secret to use

```bash
aws secretsmanager create-secret --name swiss-army-kube-sub2zero --description "My test secret created with the CLI." --secret-string "Test_it"
```

4. Check external secret created:
```kubectl describe externalsecret.external-secrets.io/swiss-army-kube-sub2zero -n kube-system```

5. Check password you have been created
```kubectl get secrets test-secrets -n kube-system -o jsonpath="{.data.cleanspeak_admin_pass}" |base64 -D```
should get get "Test_it"

6. Clean thinks up to delete

```yaml
aws secretsmanager delete-secret --secret-id swiss-army-kube-sub2zero
kubectl apply -f external_secret_example.yaml

```

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| local | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| allowed\_secrets\_prefix | Prefix of for secrets we should be able to access from the external-secrets app? | `string` | `"/eks/"` | no |
| argocd | A set of values for enabling deployment through ArgoCD | `map(string)` | `{}` | no |
| aws\_assume\_role\_arn | A role to assume | `string` | `""` | no |
| aws\_region | A name of the AWS region (us-central-1, us-west-2 and etc.) | `string` | `""` | no |
| chart\_parameters | A list of parameters that will override defaults | `list` | `[]` | no |
| chart\_parameters\_as\_string | A list of parameters that will override defaults | `list` | `[]` | no |
| chart\_repository | n/a | `string` | `"https://external-secrets.github.io/kubernetes-external-secrets/"` | no |
| chart\_values | Chart values | `string` | `""` | no |
| chart\_version | A Helm Chart version | `string` | `"6.0.0"` | no |
| cluster\_output | Cluster output object from Kubernetes module | `map` | n/a | yes |
| poller\_interval | Interval of refreshing values from secrets manager in ms | `string` | `"30000"` | no |
| tags | A tags for attaching to new created AWS resources | `map(string)` | `{}` | no |

## Outputs

No output.
