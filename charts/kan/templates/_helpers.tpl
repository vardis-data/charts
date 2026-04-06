{{- define "kan.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "kan.fullname" -}}
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

{{- define "kan.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ include "kan.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "kan.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kan.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "kan.databaseHost" -}}
{{- if .Values.postgres.enabled }}
{{- printf "%s-postgres" .Release.Name }}
{{- else }}
{{- .Values.database.host }}
{{- end }}
{{- end }}

{{- define "kan.databasePort" -}}
{{- if .Values.postgres.enabled }}
{{- 5432 }}
{{- else }}
{{- .Values.database.port }}
{{- end }}
{{- end }}

{{- define "kan.databaseName" -}}
{{- if .Values.postgres.enabled }}
{{- .Values.postgres.customUser.database }}
{{- else }}
{{- .Values.database.name }}
{{- end }}
{{- end }}

{{- define "kan.databaseUser" -}}
{{- if .Values.postgres.enabled }}
{{- .Values.postgres.customUser.name }}
{{- else }}
{{- .Values.database.user }}
{{- end }}
{{- end }}

{{- define "kan.databasePassword" -}}
{{- if .Values.postgres.enabled }}
{{- .Values.postgres.customUser.password }}
{{- else }}
{{- .Values.database.password }}
{{- end }}
{{- end }}

{{- define "kan.databaseUrl" -}}
postgresql://{{ include "kan.databaseUser" . }}:{{ include "kan.databasePassword" . }}@{{ include "kan.databaseHost" . }}:{{ include "kan.databasePort" . }}/{{ include "kan.databaseName" . }}
{{- end }}

{{- define "kan.secretName" -}}
{{- include "kan.fullname" . }}
{{- end }}

{{- define "kan.s3SecretName" -}}
{{- if .Values.s3.existingSecret.name }}
{{- .Values.s3.existingSecret.name }}
{{- else }}
{{- include "kan.secretName" . }}
{{- end }}
{{- end }}

{{- define "kan.s3AccessKeyIdKey" -}}
{{- if .Values.s3.existingSecret.name }}
{{- .Values.s3.existingSecret.keys.accessKeyId }}
{{- else }}
{{- "S3_ACCESS_KEY_ID" }}
{{- end }}
{{- end }}

{{- define "kan.smtpSecretName" -}}
{{- if .Values.smtp.existingSecret.name }}
{{- .Values.smtp.existingSecret.name }}
{{- else }}
{{- include "kan.secretName" . }}
{{- end }}
{{- end }}

{{- define "kan.smtpPasswordKey" -}}
{{- if .Values.smtp.existingSecret.name }}
{{- .Values.smtp.existingSecret.keys.password }}
{{- else }}
{{- "SMTP_PASSWORD" }}
{{- end }}
{{- end }}

{{- define "kan.s3SecretAccessKeyKey" -}}
{{- if .Values.s3.existingSecret.name }}
{{- .Values.s3.existingSecret.keys.secretAccessKey }}
{{- else }}
{{- "S3_SECRET_ACCESS_KEY" }}
{{- end }}
{{- end }}
