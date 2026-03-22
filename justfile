set quiet

# List available commands
default:
    @just --list

# Lint all charts
lint:
    helm lint charts/*

# Run unit tests for all charts
test:
    helm unittest charts/*

# Lint and test all charts
check: lint test

# Render chart templates locally
template chart:
    helm template {{ chart }} charts/{{ chart }}

# Package a chart
package chart:
    helm package charts/{{ chart }}

# Generate index.html locally (requires index.yaml)
generate-index:
    uv run scripts/index.py index.yaml index.html
