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

### Deployment

- `common.deployment-annotations` - Deployment annotations with checksums
- `common.container-ports` - Standard HTTP container port
- `common.liveness-probe` - HTTP liveness probe
- `common.readiness-probe` - HTTP readiness probe

### Database

- `common.database-host` - Database host (embedded or external)
- `common.database-port` - Database port
- `common.database-name` - Database name
- `common.database-url` - PostgreSQL connection string

## Example

```yaml
# templates/ingress.yaml
{{- include "common.tailscale-ingress" . }}

# templates/service.yaml
{{- include "common.service" . }}

# values.yaml
tailscale:
  enabled: true
  hostname: myapp

service:
  port: 80
```
