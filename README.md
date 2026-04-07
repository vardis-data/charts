# Vardis Helm Charts

Helm chart repository for Vardis infrastructure, published to GitHub Container Registry (GHCR).

## Usage

All charts are distributed via OCI registry at `ghcr.io/vardis-data/charts`.

### Installing a chart

```bash
helm install my-release oci://ghcr.io/vardis-data/charts/CHART_NAME --version VERSION
```

### Example: Installing docmost

```bash
helm install docmost oci://ghcr.io/vardis-data/charts/docmost --version 1.3.0
```

### Searching available versions

```bash
helm show chart oci://ghcr.io/vardis-data/charts/CHART_NAME
```

### Using as Terraform/OpenTofu dependency

```hcl
resource "helm_release" "example" {
  name       = "my-release"
  repository = "oci://ghcr.io/vardis-data/charts"
  chart      = "CHART_NAME"
  version    = "VERSION"
}
```

## Development

### Prerequisites

- [Helm](https://helm.sh/docs/intro/install/)
- [helm-unittest](https://github.com/helm-unittest/helm-unittest)

### Linting

```bash
helm lint charts/*
```

### Running Tests

```bash
helm unittest charts/CHART_NAME
```

### Local Rendering

```bash
helm template my-release charts/CHART_NAME
```

### Publishing Charts

Charts are automatically published to GHCR when changes are pushed to the `main` branch. See `.github/workflows/release.yaml` for details.
