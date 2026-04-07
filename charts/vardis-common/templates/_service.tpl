{{/*
Standard Kubernetes Service
Creates a ClusterIP service with common configuration

Usage:
  {{- include "vardis-common.service" . }}

Required values:
  service:
    port: 80

Optional values:
  service:
    type: ClusterIP        # defaults to ClusterIP
    targetPort: http       # defaults to "http"
    annotations: {}
*/}}
{{- define "vardis-common.service" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "vardis-common.fullname" . }}
  labels:
    {{- include "vardis-common.labels" . | nindent 4 }}
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
    {{- include "vardis-common.selectorLabels" . | nindent 4 }}
{{- end }}
