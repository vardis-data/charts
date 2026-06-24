{{/*
Tailscale ingress
Exposes a Service to the tailnet via a Tailscale Ingress resource

Usage:
  {{- include "common.ingress.tailscale" . }}

Required values:
  ingress:
    tailscale:
      enabled: true
      hostname: "myapp"
  service:
    port: 80

Optional values:
  ingress:
    tailscale:
      tags: "tag:k8s-myapp"  # defaults to tag:k8s-{hostname}
      annotations: {}         # additional annotations
*/}}
{{- define "common.ingress.tailscale" -}}
{{- if .Values.ingress.tailscale.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  annotations:
    tailscale.com/hostname: {{ .Values.ingress.tailscale.hostname | required ".Values.ingress.tailscale.hostname is required when ingress.type is tailscale" }}
    tailscale.com/tags: {{ .Values.ingress.tailscale.tags | default (printf "tag:k8s-%s" .Values.ingress.tailscale.hostname) }}
    {{- with .Values.ingress.tailscale.annotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  ingressClassName: tailscale
  tls:
    - hosts:
        - {{ .Values.ingress.tailscale.hostname }}
  defaultBackend:
    service:
      name: {{ include "common.fullname" . }}
      port:
        number: {{ .Values.service.port }}
{{- end }}
{{- end }}

{{/*
Traefik ingress
Exposes a Service via a Traefik Ingress resource

Usage:
  {{- include "common.ingress.traefik" . }}

Required values:
  ingress:
    traefik:
      enabled: true
      hosts:
        - host: myapp.example.com
          paths:
            - path: /
              pathType: Prefix
      service:
        port: 80

Optional values:
  ingress:
    traefik:
      className: traefik
      tls: []
      annotations: {}
*/}}
{{- define "common.ingress.traefik" -}}
{{- if .Values.ingress.traefik.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.ingress.traefik.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  ingressClassName: {{ .Values.ingress.traefik.className | default "traefik" }}
  {{- with .Values.ingress.traefik.tls }}
  tls:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  rules:
    {{- range .Values.ingress.traefik.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType | default "Prefix" }}
            backend:
              service:
                name: {{ include "common.fullname" $ }}
                port:
                  number: {{ $.Values.ingress.traefik.service.port }}
          {{- end }}
    {{- end }}
{{- end }}
{{- end }}
