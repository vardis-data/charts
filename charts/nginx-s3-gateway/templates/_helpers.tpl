{{/*
Import common templates from vardis-common library
*/}}

{{- define "nginx-s3-gateway.name" -}}
{{- include "vardis-common.name" . }}
{{- end }}

{{- define "nginx-s3-gateway.fullname" -}}
{{- include "vardis-common.fullname" . }}
{{- end }}

{{- define "nginx-s3-gateway.chart" -}}
{{- include "vardis-common.chart" . }}
{{- end }}

{{- define "nginx-s3-gateway.labels" -}}
{{- include "vardis-common.labels" . }}
{{- end }}

{{- define "nginx-s3-gateway.selectorLabels" -}}
{{- include "vardis-common.selectorLabels" . }}
{{- end }}
