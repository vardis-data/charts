{{/*
Database host helper
Returns the database host, either from embedded postgres or external

Usage:
  {{ include "common.database-host" . }}

Required for embedded postgres:
  postgres:
    enabled: true

Required for external database:
  database:
    host: "postgres.example.com"
*/}}
{{- define "common.database-host" -}}
{{- if .Values.postgres.enabled }}
{{- printf "%s-postgres" .Release.Name }}
{{- else }}
{{- .Values.database.host | required ".Values.database.host is required when postgres.enabled is false" }}
{{- end }}
{{- end }}

{{/*
Database port helper
Returns the database port, either from embedded postgres or external

Usage:
  {{ include "common.database-port" . }}
*/}}
{{- define "common.database-port" -}}
{{- if .Values.postgres.enabled }}
{{- 5432 }}
{{- else }}
{{- .Values.database.port | default 5432 }}
{{- end }}
{{- end }}

{{/*
Database name helper
Returns the database name, either from embedded postgres or external

Usage:
  {{ include "common.database-name" . }}
*/}}
{{- define "common.database-name" -}}
{{- if .Values.postgres.enabled }}
{{- .Values.postgres.customUser.database | default "postgres" }}
{{- else }}
{{- .Values.database.name | required ".Values.database.name is required when postgres.enabled is false" }}
{{- end }}
{{- end }}

{{/*
Database connection string helper
Returns a PostgreSQL connection string

Usage:
  {{ include "common.database-url" . }}

Optional values:
  database:
    ssl: true  # adds sslmode=require
*/}}
{{- define "common.database-url" -}}
{{- $host := include "common.database-host" . }}
{{- $port := include "common.database-port" . }}
{{- $name := include "common.database-name" . }}
{{- $ssl := "" }}
{{- if .Values.database.ssl }}
{{- $ssl = "?sslmode=require" }}
{{- end }}
{{- printf "postgresql://${DB_USER}:${DB_PASSWORD}@%s:%v/%s%s" $host $port $name $ssl }}
{{- end }}
