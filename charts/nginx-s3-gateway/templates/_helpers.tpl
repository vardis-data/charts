{{/*
Import common templates from common library
*/}}

{{- define "nginx-s3-gateway.name" -}}
{{- include "common.name" . }}
{{- end }}

{{- define "nginx-s3-gateway.fullname" -}}
{{- include "common.fullname" . }}
{{- end }}

{{- define "nginx-s3-gateway.chart" -}}
{{- include "common.chart" . }}
{{- end }}

{{- define "nginx-s3-gateway.labels" -}}
{{- include "common.labels" . }}
{{- end }}

{{- define "nginx-s3-gateway.selectorLabels" -}}
{{- include "common.selectorLabels" . }}
{{- end }}
