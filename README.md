# Vardis Helm Charts

Helm chart repository for Vardis infrastructure.

## Usage

```bash
helm repo add vardis https://vardis-data.github.io/charts
helm repo update
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
helm unittest charts/system-upgrade-controller
```

### Local Rendering

```bash
helm template system-upgrade-controller charts/system-upgrade-controller
```
