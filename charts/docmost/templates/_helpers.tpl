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

{{- define "docmost.databaseHost" -}}
{{- if .Values.postgres.enabled }}
{{- printf "%s-postgres" .Release.Name }}
{{- else }}
{{- .Values.database.host }}
{{- end }}
{{- end }}

{{- define "docmost.databasePort" -}}
{{- if .Values.postgres.enabled }}
{{- 5432 }}
{{- else }}
{{- .Values.database.port }}
{{- end }}
{{- end }}

{{- define "docmost.databaseName" -}}
{{- if .Values.postgres.enabled }}
{{- .Values.postgres.customUser.database }}
{{- else }}
{{- .Values.database.name }}
{{- end }}
{{- end }}

{{- define "docmost.databaseUser" -}}
{{- if .Values.postgres.enabled }}
{{- .Values.postgres.customUser.name }}
{{- else }}
{{- .Values.database.user }}
{{- end }}
{{- end }}

{{- define "docmost.databasePassword" -}}
{{- if .Values.postgres.enabled }}
{{- .Values.postgres.customUser.password }}
{{- else }}
{{- .Values.database.password }}
{{- end }}
{{- end }}

{{- define "docmost.databaseUrl" -}}
postgresql://{{ include "docmost.databaseUser" . }}:{{ include "docmost.databasePassword" . }}@{{ include "docmost.databaseHost" . }}:{{ include "docmost.databasePort" . }}/{{ include "docmost.databaseName" . }}?schema=public
{{- end }}

{{- define "docmost.redisHost" -}}
{{- if .Values.valkey.enabled }}
{{- printf "%s-valkey" .Release.Name }}
{{- else }}
{{- .Values.redis.host }}
{{- end }}
{{- end }}

{{- define "docmost.redisPort" -}}
{{- if .Values.valkey.enabled }}
{{- .Values.valkey.service.port | default 6379 }}
{{- else }}
{{- .Values.redis.port }}
{{- end }}
{{- end }}

{{- define "docmost.redisPassword" -}}
{{- if .Values.valkey.enabled }}
{{- .Values.valkey.password }}
{{- else }}
{{- .Values.redis.password }}
{{- end }}
{{- end }}

{{- define "docmost.redisUrl" -}}
{{- $password := include "docmost.redisPassword" . -}}
{{- if $password -}}
redis://default:{{ $password }}@{{ include "docmost.redisHost" . }}:{{ include "docmost.redisPort" . }}
{{- else -}}
redis://{{ include "docmost.redisHost" . }}:{{ include "docmost.redisPort" . }}
{{- end -}}
{{- end }}

{{- define "docmost.secretName" -}}
{{- include "docmost.fullname" . }}
{{- end }}

{{- define "docmost.s3SecretName" -}}
{{- if .Values.s3.existingSecret.name }}
{{- .Values.s3.existingSecret.name }}
{{- else }}
{{- include "docmost.secretName" . }}
{{- end }}
{{- end }}

{{- define "docmost.s3AccessKeyIdKey" -}}
{{- if .Values.s3.existingSecret.name }}
{{- .Values.s3.existingSecret.keys.accessKeyId }}
{{- else }}
{{- "AWS_S3_ACCESS_KEY_ID" }}
{{- end }}
{{- end }}

{{- define "docmost.smtpSecretName" -}}
{{- if .Values.smtp.existingSecret.name }}
{{- .Values.smtp.existingSecret.name }}
{{- else }}
{{- include "docmost.secretName" . }}
{{- end }}
{{- end }}

{{- define "docmost.smtpPasswordKey" -}}
{{- if .Values.smtp.existingSecret.name }}
{{- .Values.smtp.existingSecret.keys.password }}
{{- else }}
{{- "SMTP_PASSWORD" }}
{{- end }}
{{- end }}

{{- define "docmost.s3SecretAccessKeyKey" -}}
{{- if .Values.s3.existingSecret.name }}
{{- .Values.s3.existingSecret.keys.secretAccessKey }}
{{- else }}
{{- "AWS_S3_SECRET_ACCESS_KEY" }}
{{- end }}
{{- end }}
