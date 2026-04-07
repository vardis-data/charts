# Vardis Common Helm Library

Common Helm templates for Vardis charts.

## Usage

Add as a dependency in your `Chart.yaml`:

```yaml
dependencies:
  - name: vardis-common
    version: 1.0.0
    repository: "https://vardis-data.github.io/charts"
```

## Available Templates

### Names

- `vardis-common.name` - Chart name
- `vardis-common.fullname` - Full resource name
- `vardis-common.chart` - Chart name and version

### Labels

- `vardis-common.labels` - Standard Kubernetes labels
- `vardis-common.selectorLabels` - Pod selector labels

### Ingress

- `vardis-common.tailscale-ingress` - Tailscale ingress resource
- `vardis-common.traefik-ingress` - Traefik ingress resource

### Service

- `vardis-common.service` - Standard ClusterIP service

### Deployment

- `vardis-common.deployment-annotations` - Deployment annotations with checksums
- `vardis-common.container-ports` - Standard HTTP container port
- `vardis-common.liveness-probe` - HTTP liveness probe
- `vardis-common.readiness-probe` - HTTP readiness probe

### Database

- `vardis-common.database-host` - Database host (embedded or external)
- `vardis-common.database-port` - Database port
- `vardis-common.database-name` - Database name
- `vardis-common.database-url` - PostgreSQL connection string

## Example

```yaml
# templates/ingress.yaml
{{- include "vardis-common.tailscale-ingress" . }}

# templates/service.yaml
{{- include "vardis-common.service" . }}

# values.yaml
tailscale:
  enabled: true
  hostname: myapp

service:
  port: 80
```
