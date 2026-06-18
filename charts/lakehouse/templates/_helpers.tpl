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

{{/* Password secret helpers */}}
{{- define "lakehouse.passwordSecretName" -}}
{{- if .Values.postgres.passwordSecret.name }}
{{- .Values.postgres.passwordSecret.name }}
{{- else }}
{{- include "lakehouse.fullname" . }}
{{- end }}
{{- end }}

{{- define "lakehouse.passwordKey" -}}
{{- if .Values.postgres.passwordSecret.name }}
{{- .Values.postgres.passwordSecret.key }}
{{- else }}
{{- "password" }}
{{- end }}
{{- end }}

{{/* S3 secret helpers */}}
{{- define "lakehouse.s3SecretName" -}}
{{- if .Values.s3.existingSecret.name }}
{{- .Values.s3.existingSecret.name }}
{{- else }}
{{- include "lakehouse.fullname" . }}
{{- end }}
{{- end }}

{{- define "lakehouse.s3AccessKeyIdKey" -}}
{{- if .Values.s3.existingSecret.name }}
{{- .Values.s3.existingSecret.keys.accessKeyId }}
{{- else }}
{{- "s3AccessKeyId" }}
{{- end }}
{{- end }}

{{- define "lakehouse.s3SecretAccessKeyKey" -}}
{{- if .Values.s3.existingSecret.name }}
{{- .Values.s3.existingSecret.keys.secretAccessKey }}
{{- else }}
{{- "s3SecretAccessKey" }}
{{- end }}
{{- end }}

{{/* Nessie password secret helpers */}}
{{- define "lakehouse.nessiePasswordSecretName" -}}
{{- if .Values.nessie.postgres.existingSecret.name }}
{{- .Values.nessie.postgres.existingSecret.name }}
{{- else }}
{{- include "lakehouse.metadata.secretName" . }}
{{- end }}
{{- end }}

{{- define "lakehouse.nessiePasswordKey" -}}
{{- if .Values.nessie.postgres.existingSecret.name }}
{{- .Values.nessie.postgres.existingSecret.key }}
{{- else }}
password
{{- end }}
{{- end }}

{{/* Shared env vars injected into primary and replica containers */}}
{{- define "lakehouse.env" -}}
- name: PGDATA
  value: /var/lib/postgresql/data/pgdata
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "lakehouse.passwordSecretName" . | quote }}
      key: {{ include "lakehouse.passwordKey" . | quote }}
{{- if or .Values.s3.accessKeyId .Values.s3.existingSecret.name }}
- name: S3_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ include "lakehouse.s3SecretName" . | quote }}
      key: {{ include "lakehouse.s3AccessKeyIdKey" . | quote }}
- name: S3_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "lakehouse.s3SecretName" . | quote }}
      key: {{ include "lakehouse.s3SecretAccessKeyKey" . | quote }}
{{- end }}
{{- end }}

{{- define "lakehouse.volumeMounts" -}}
- name: data
  mountPath: /var/lib/postgresql/data
{{- end }}

{{- define "lakehouse.preloadArgs" -}}
{{- $libs := prepend .Values.extensions.sharedPreloadLibraries "pg_duckdb" | uniq }}
- "-c"
- "shared_preload_libraries={{ join "," $libs }}"
{{- end }}

{{- define "lakehouse.nessieExtraEnv" -}}
{{- if .Values.nessie.warehouseLocation }}
- name: NESSIE_CATALOG_WAREHOUSES__{{ .Values.nessie.warehouseName | upper }}__LOCATION
  value: {{ .Values.nessie.warehouseLocation | quote }}
{{ end }}
{{ if .Values.s3.region }}
- name: NESSIE_CATALOG_SERVICE_S3_DEFAULT_OPTIONS_REGION
  value: {{ .Values.s3.region | quote }}
{{ end }}
{{ if .Values.s3.endpoint }}
- name: NESSIE_CATALOG_SERVICE_S3_DEFAULT_OPTIONS_ENDPOINT
  value: "https://{{ .Values.s3.endpoint }}"
{{ end }}
{{ if eq .Values.s3.urlStyle "path" }}
- name: NESSIE_CATALOG_SERVICE_S3_DEFAULT_OPTIONS_PATH_STYLE_ACCESS
  value: "true"
{{ end }}
{{ if or .Values.s3.accessKeyId .Values.s3.existingSecret.name }}
- name: NESSIE_CATALOG_SERVICE_S3_DEFAULT_OPTIONS_ACCESS_KEY
  value: "urn:nessie-secret:quarkus:s3-credentials"
- name: S3_CREDENTIALS
  valueFrom:
    secretKeyRef:
      name: {{ if .Values.s3.existingSecret.name }}{{ .Values.s3.existingSecret.name | quote }}{{ else }}{{ include "lakehouse.fullname" . | quote }}{{ end }}
      key: {{ if .Values.s3.existingSecret.name }}{{ .Values.s3.existingSecret.keys.credentials | quote }}{{ else }}"s3Credentials"{{ end }}
{{ end }}
{{- end }}

{{- define "lakehouse.probes" -}}
livenessProbe:
  exec:
    command:
      - pg_isready
      - -U
      - {{ .Values.postgres.user | quote }}
      - -d
      - {{ .Values.postgres.database | quote }}
  initialDelaySeconds: 30
  periodSeconds: 10
readinessProbe:
  exec:
    command:
      - pg_isready
      - -U
      - {{ .Values.postgres.user | quote }}
      - -d
      - {{ .Values.postgres.database | quote }}
  initialDelaySeconds: 5
  periodSeconds: 5
{{- end }}

{{- define "lakehouse.exporter" -}}
- name: postgres-exporter
  image: "{{ .Values.metrics.image.repository }}:{{ .Values.metrics.image.tag }}"
  imagePullPolicy: {{ .Values.metrics.image.pullPolicy }}
  ports:
    - name: metrics
      containerPort: {{ .Values.metrics.port }}
      protocol: TCP
  env:
    - name: DATA_SOURCE_URI
      value: "localhost:{{ .Values.postgres.port }}/{{ .Values.postgres.database }}?sslmode=disable"
    - name: DATA_SOURCE_USER
      value: {{ .Values.postgres.user | quote }}
    - name: DATA_SOURCE_PASS
      valueFrom:
        secretKeyRef:
          name: {{ include "lakehouse.passwordSecretName" . }}
          key: {{ include "lakehouse.passwordKey" . }}
  {{- with .Values.metrics.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}

{{/* PostgREST JWT secret helpers */}}
{{- define "lakehouse.postgrest.jwtSecretName" -}}
{{- if .Values.postgrest.jwt.existingSecret.name }}
{{- .Values.postgrest.jwt.existingSecret.name }}
{{- else }}
{{- include "lakehouse.fullname" . }}-postgrest
{{- end }}
{{- end }}

{{- define "lakehouse.postgrest.jwtSecretKey" -}}
{{- if .Values.postgrest.jwt.existingSecret.name }}
{{- .Values.postgrest.jwt.existingSecret.key }}
{{- else }}
{{- "jwt-secret" }}
{{- end }}
{{- end }}

{{/* Nessie JDBC URL pointing to the primary pg-duckdb pod */}}
{{- define "lakehouse.nessie.jdbcUrl" -}}
{{- printf "jdbc:postgresql://%s:%s/%s" (include "lakehouse.metadata.host" .) (include "lakehouse.metadata.port" .) .Values.nessie.postgres.database }}
{{- end }}

{{- define "lakehouse.metadata.host" -}}
{{- if .Values.metadata.external.host }}
{{- .Values.metadata.external.host }}
{{- else }}
{{- include "lakehouse.fullname" . }}-metadata
{{- end }}
{{- end }}

{{- define "lakehouse.metadata.port" -}}
{{- if .Values.metadata.external.host }}
{{- .Values.metadata.external.port | int }}
{{- else }}
5432
{{- end }}
{{- end }}

{{- define "lakehouse.metadata.secretName" -}}
{{- if .Values.metadata.external.secretName }}
{{- .Values.metadata.external.secretName }}
{{- else }}
{{- include "lakehouse.fullname" . }}-metadata
{{- end }}
{{- end }}
