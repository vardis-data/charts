{{/*
Tailscale exposure
Exposes a Service to the tailnet via a Tailscale Ingress resource

Usage:
  {{- include "common.tailscale-exposure" . }}

Required values:
  tailscale:
    enabled: true
    hostname: "myapp"
  service:
    port: 80

Optional values:
  tailscale:
    tags: "tag:k8s-myapp"  # defaults to tag:k8s-{hostname}
    annotations: {}         # additional annotations
*/}}
{{- define "common.tailscale-exposure" -}}
{{- if .Values.tailscale.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  annotations:
    tailscale.com/hostname: {{ .Values.tailscale.hostname | required ".Values.tailscale.hostname is required when tailscale.enabled is true" }}
    tailscale.com/tags: {{ .Values.tailscale.tags | default (printf "tag:k8s-%s" .Values.tailscale.hostname) }}
    {{- with .Values.tailscale.annotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  ingressClassName: tailscale
  tls:
    - hosts:
        - {{ .Values.tailscale.hostname }}
  defaultBackend:
    service:
      name: {{ include "common.fullname" . }}
      port:
        number: {{ .Values.service.port }}
{{- end }}
{{- end }}
