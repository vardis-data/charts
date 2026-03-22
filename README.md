# Vardis Helm Charts

Helm chart repository for Vardis infrastructure.

## Usage

```bash
helm repo add vardis https://vardis.github.io/charts
helm repo update
```

## Available Charts

| Chart                                                           | Description                                                                   |
| --------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| [system-upgrade-controller](./charts/system-upgrade-controller) | Deploys Rancher's System Upgrade Controller for automated K3s and OS upgrades |

## Installing a Chart

```bash
helm install system-upgrade-controller vardis/system-upgrade-controller \
  --namespace system-upgrade \
  --create-namespace
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
