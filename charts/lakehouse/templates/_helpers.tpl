{{- define "lakehouse.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "lakehouse.fullname" -}}
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

{{- define "lakehouse.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ include "lakehouse.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "lakehouse.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lakehouse.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* ClickHouse secret helpers */}}
{{- define "lakehouse.clickhouse.secretName" -}}
{{- if .Values.clickhouse.existingSecret.name }}
{{- .Values.clickhouse.existingSecret.name }}
{{- else }}
{{- include "lakehouse.fullname" . }}-clickhouse
{{- end }}
{{- end }}

{{- define "lakehouse.clickhouse.secretKey" -}}
{{- if .Values.clickhouse.existingSecret.name }}
{{- .Values.clickhouse.existingSecret.key }}
{{- else }}
{{- "password" }}
{{- end }}
{{- end }}

{{/* S3 secret helpers */}}
{{- define "lakehouse.s3.secretName" -}}
{{- if .Values.s3.existingSecret.name }}
{{- .Values.s3.existingSecret.name }}
{{- else }}
{{- include "lakehouse.fullname" . }}-s3
{{- end }}
{{- end }}

{{- define "lakehouse.s3.accessKeyIdKey" -}}
{{- if .Values.s3.existingSecret.name }}
{{- .Values.s3.existingSecret.keys.accessKeyId }}
{{- else }}
{{- "s3AccessKeyId" }}
{{- end }}
{{- end }}

{{- define "lakehouse.s3.secretAccessKeyKey" -}}
{{- if .Values.s3.existingSecret.name }}
{{- .Values.s3.existingSecret.keys.secretAccessKey }}
{{- else }}
{{- "s3SecretAccessKey" }}
{{- end }}
{{- end }}

{{/* Cube JWT secret helpers */}}
{{- define "lakehouse.cube.jwtSecretName" -}}
{{- include "lakehouse.fullname" . }}-cube
{{- end }}

{{/* ClickHouse host for Cube connection */}}
{{- define "lakehouse.clickhouse.host" -}}
{{- include "lakehouse.fullname" . }}
{{- end }}
