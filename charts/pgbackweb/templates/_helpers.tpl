{{- define "pgbackweb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "pgbackweb.fullname" -}}
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

{{- define "pgbackweb.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ include "pgbackweb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "pgbackweb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pgbackweb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "pgbackweb.databaseHost" -}}
{{- if .Values.postgres.enabled }}
{{- printf "%s-postgres" .Release.Name }}
{{- else }}
{{- .Values.database.host }}
{{- end }}
{{- end }}

{{- define "pgbackweb.databasePort" -}}
{{- if .Values.postgres.enabled }}
{{- 5432 }}
{{- else }}
{{- .Values.database.port }}
{{- end }}
{{- end }}

{{- define "pgbackweb.databaseName" -}}
{{- if .Values.postgres.enabled }}
{{- .Values.postgres.customUser.database }}
{{- else }}
{{- .Values.database.name }}
{{- end }}
{{- end }}

{{- define "pgbackweb.databaseUser" -}}
{{- if .Values.postgres.enabled }}
{{- .Values.postgres.customUser.name }}
{{- else }}
{{- .Values.database.user }}
{{- end }}
{{- end }}

{{- define "pgbackweb.databasePassword" -}}
{{- if .Values.postgres.enabled }}
{{- .Values.postgres.customUser.password }}
{{- else }}
{{- .Values.database.password }}
{{- end }}
{{- end }}

{{- define "pgbackweb.databaseSslMode" -}}
{{- if .Values.postgres.enabled }}
{{- "disable" }}
{{- else }}
{{- .Values.database.sslMode }}
{{- end }}
{{- end }}

{{- define "pgbackweb.databaseUrl" -}}
postgresql://{{ include "pgbackweb.databaseUser" . }}:{{ include "pgbackweb.databasePassword" . }}@{{ include "pgbackweb.databaseHost" . }}:{{ include "pgbackweb.databasePort" . }}/{{ include "pgbackweb.databaseName" . }}?sslmode={{ include "pgbackweb.databaseSslMode" . }}
{{- end }}
