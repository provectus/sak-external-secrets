# Step to test scenario

create new external secret:

1. terraform apply modile

2. in kubernetes kubectl apply -f external_secret_example.yaml

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
  name: example
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
      key: example
```

3. in AWS SecretManager create secret to use

```bash
aws secretsmanager create-secret --name swiss-army-kube-sub2zero --description "My test secret created with the CLI." --secret-string "Test_it"
```

4. check external secret created:
``` k describe externalsecret.external-secrets.io/swiss-army-kube-sub2zero -n kube-system ```

5. Check password you have been created
```k get secrets test-secrets -n kube-system -o jsonpath="{.data.cleanspeak_admin_pass}" |base64 -D```
shoul get get "Test_it"

6. Clean thinks up to delete ```bash
aws secretsmanager delete-secret --secret-id swiss-army-kube-sub2zero
kubectl apply -f external_secret_example.yaml

```
