{{/*
Standard Kubernetes Service
Creates a ClusterIP service with common configuration

Usage:
  {{- include "common.service" . }}

Required values:
  service:
    port: 80

Optional values:
  service:
    type: ClusterIP        # defaults to ClusterIP
    targetPort: http       # defaults to "http"
    annotations: {}
*/}}
{{- define "common.service" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.service.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  type: {{ .Values.service.type | default "ClusterIP" }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort | default "http" }}
      protocol: TCP
      name: http
  selector:
    {{- include "common.selectorLabels" . | nindent 4 }}
{{- end }}
