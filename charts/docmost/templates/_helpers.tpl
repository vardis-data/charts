{{- define "docmost.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "docmost.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "docmost.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ include "docmost.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "docmost.selectorLabels" -}}
app.kubernetes.io/name: {{ include "docmost.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "docmost.databaseUrl" -}}
postgresql://{{ .Values.database.user }}:{{ .Values.database.password }}@{{ .Values.database.host }}:{{ .Values.database.port }}/{{ .Values.database.name }}?schema=public
{{- end }}

{{- define "docmost.redisUrl" -}}
{{- if .Values.redis.password }}
redis://default:{{ .Values.redis.password }}@{{ .Values.redis.host }}:{{ .Values.redis.port }}
{{- else }}
redis://{{ .Values.redis.host }}:{{ .Values.redis.port }}
{{- end }}
{{- end }}
