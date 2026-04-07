{{/*
Common deployment annotations
Includes checksum of ConfigMap and Secret for auto-restart on changes

Usage:
  annotations:
    {{- include "vardis-common.deployment-annotations" . | nindent 4 }}
*/}}
{{- define "vardis-common.deployment-annotations" -}}
{{- if .Values.configMap }}
checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
{{- end }}
{{- if .Values.secret }}
checksum/secret: {{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}
{{- end }}
{{- with .Values.podAnnotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Common container ports
Creates a standard HTTP port configuration

Usage in container spec:
  ports:
    {{- include "vardis-common.container-ports" . | nindent 4 }}

Optional values:
  containerPort: 8080  # defaults to 80
*/}}
{{- define "vardis-common.container-ports" -}}
- name: http
  containerPort: {{ .Values.containerPort | default 80 }}
  protocol: TCP
{{- end }}

{{/*
Common liveness probe
Standard HTTP liveness probe

Usage:
  livenessProbe:
    {{- include "vardis-common.liveness-probe" . | nindent 4 }}

Optional values:
  livenessProbe:
    path: /health           # defaults to /health
    initialDelaySeconds: 10
    periodSeconds: 10
*/}}
{{- define "vardis-common.liveness-probe" -}}
httpGet:
  path: {{ .Values.livenessProbe.path | default "/health" }}
  port: http
initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds | default 10 }}
periodSeconds: {{ .Values.livenessProbe.periodSeconds | default 10 }}
{{- end }}

{{/*
Common readiness probe
Standard HTTP readiness probe

Usage:
  readinessProbe:
    {{- include "vardis-common.readiness-probe" . | nindent 4 }}

Optional values:
  readinessProbe:
    path: /health           # defaults to /health
    initialDelaySeconds: 5
    periodSeconds: 5
*/}}
{{- define "vardis-common.readiness-probe" -}}
httpGet:
  path: {{ .Values.readinessProbe.path | default "/health" }}
  port: http
initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds | default 5 }}
periodSeconds: {{ .Values.readinessProbe.periodSeconds | default 5 }}
{{- end }}
