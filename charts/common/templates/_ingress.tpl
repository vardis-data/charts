{{/*
Tailscale Ingress
Creates a Tailscale ingress resource

Usage:
  {{- include "common.tailscale-ingress" . }}

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
{{- define "common.tailscale-ingress" -}}
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

{{/*
Traefik Ingress with common configuration
Creates a Traefik ingress resource with standard settings

Usage:
  {{- include "common.traefik-ingress" . }}

Required values:
  ingress:
    enabled: true
    className: traefik
    hosts:
      - host: example.com
        paths:
          - path: /
            pathType: Prefix
  service:
    port: 80

Optional values:
  ingress:
    annotations: {}
    tls:
      - secretName: example-tls
        hosts:
          - example.com
*/}}
{{- define "common.traefik-ingress" -}}
{{- if and .Values.ingress.enabled (eq .Values.ingress.className "traefik") }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  ingressClassName: {{ .Values.ingress.className }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: {{ include "common.fullname" $ }}
                port:
                  number: {{ $.Values.service.port }}
          {{- end }}
    {{- end }}
{{- end }}
{{- end }}
