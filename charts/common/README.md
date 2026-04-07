# Common Helm Library

Common Helm templates for Vardis charts.

## Usage

Add as a dependency in your `Chart.yaml`:

```yaml
dependencies:
  - name: common
    version: 1.0.0
    repository: "https://vardis-data.github.io/charts"
```

## Available Templates

### Names

- `common.name` - Chart name
- `common.fullname` - Full resource name
- `common.chart` - Chart name and version

### Labels

- `common.labels` - Standard Kubernetes labels
- `common.selectorLabels` - Pod selector labels

### Ingress

- `common.tailscale-ingress` - Tailscale ingress resource
- `common.traefik-ingress` - Traefik ingress resource

### Service

- `common.service` - Standard ClusterIP service

### Resources

- `common.secret` - Kubernetes Secret with auto-base64 encoding
- `common.configmap` - Kubernetes ConfigMap
- `common.serviceaccount` - Kubernetes ServiceAccount
- `common.pvc` - PersistentVolumeClaim
- `common.hpa` - HorizontalPodAutoscaler

### Environment Variables

- `common.s3-env` - S3/object storage environment variables
- `common.smtp-env` - SMTP environment variables
- `common.env-secret` - Single env var from secret
- `common.env-configmap` - Single env var from configmap

### Deployment Helpers

- `common.deployment-annotations` - Deployment annotations with checksums
- `common.container-ports` - Standard HTTP container port
- `common.liveness-probe` - HTTP liveness probe
- `common.readiness-probe` - HTTP readiness probe

### Database Helpers

- `common.database-host` - Database host (embedded or external)
- `common.database-port` - Database port
- `common.database-name` - Database name
- `common.database-url` - PostgreSQL connection string

### Utility Helpers

- `common.serviceAccountName` - ServiceAccount name resolver

## Examples

### Tailscale Ingress

```yaml
# templates/ingress.yaml
{{- include "common.tailscale-ingress" . }}

# values.yaml
tailscale:
  enabled: true
  hostname: myapp
```

### S3 Environment Variables

```yaml
# templates/deployment.yaml
spec:
  containers:
    - name: app
      env:
        {{- include "common.s3-env" . | nindent 8 }}

# values.yaml
s3:
  enabled: true
  secretName: s3-credentials
  region: us-east-1
  bucket: my-bucket
  endpoint: https://s3.amazonaws.com
```

### SMTP Environment Variables

```yaml
# templates/deployment.yaml
spec:
  containers:
    - name: app
      env:
        {{- include "common.smtp-env" . | nindent 8 }}

# values.yaml
smtp:
  enabled: true
  host: smtp.example.com
  port: 587
  username: user@example.com
  secretName: smtp-credentials
  secure: "true"
```

### Secret

```yaml
# templates/secret.yaml
{{- include "common.secret" . }}

# values.yaml
secret:
  data:
    password: "my-plaintext-password"  # auto-base64 encoded
    api-key: "my-api-key"
```

### ConfigMap

```yaml
# templates/configmap.yaml
{{- include "common.configmap" . }}

# values.yaml
configMap:
  data:
    config.yaml: |
      server:
        port: 8080
```

### ServiceAccount

```yaml
# templates/serviceaccount.yaml
{{- include "common.serviceaccount" . }}

# values.yaml
serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789:role/my-role
```

### PersistentVolumeClaim

```yaml
# templates/pvc.yaml
{{- include "common.pvc" . }}

# values.yaml
persistence:
  enabled: true
  size: 10Gi
  storageClass: standard
  accessMode: ReadWriteOnce
```

### HorizontalPodAutoscaler

```yaml
# templates/hpa.yaml
{{- include "common.hpa" . }}

# values.yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80
```
