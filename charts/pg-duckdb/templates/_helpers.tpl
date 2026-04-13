{{- define "pg-duckdb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "pg-duckdb.fullname" -}}
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

{{- define "pg-duckdb.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ include "pg-duckdb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "pg-duckdb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pg-duckdb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "pg-duckdb.secretName" -}}
{{- include "pg-duckdb.fullname" . }}
{{- end }}

{{- define "pg-duckdb.passwordSecretName" -}}
{{- if .Values.passwordSecret.name }}
{{- .Values.passwordSecret.name }}
{{- else }}
{{- include "pg-duckdb.secretName" . }}
{{- end }}
{{- end }}

{{- define "pg-duckdb.passwordKey" -}}
{{- if .Values.passwordSecret.name }}
{{- .Values.passwordSecret.key }}
{{- else }}
{{- "password" }}
{{- end }}
{{- end }}

{{- define "pg-duckdb.s3SecretName" -}}
{{- if .Values.s3.existingSecret.name }}
{{- .Values.s3.existingSecret.name }}
{{- else }}
{{- include "pg-duckdb.secretName" . }}
{{- end }}
{{- end }}

{{- define "pg-duckdb.s3AccessKeyIdKey" -}}
{{- if .Values.s3.existingSecret.name }}
{{- .Values.s3.existingSecret.keys.accessKeyId }}
{{- else }}
{{- "s3AccessKeyId" }}
{{- end }}
{{- end }}

{{- define "pg-duckdb.s3SecretAccessKeyKey" -}}
{{- if .Values.s3.existingSecret.name }}
{{- .Values.s3.existingSecret.keys.secretAccessKey }}
{{- else }}
{{- "s3SecretAccessKey" }}
{{- end }}
{{- end }}

{{- define "pg-duckdb.env" -}}
- name: PGDATA
  value: /var/lib/postgresql/data/pgdata
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "pg-duckdb.passwordSecretName" . }}
      key: {{ include "pg-duckdb.passwordKey" . }}
{{- if or .Values.s3.accessKeyId .Values.s3.existingSecret.name }}
- name: S3_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ include "pg-duckdb.s3SecretName" . }}
      key: {{ include "pg-duckdb.s3AccessKeyIdKey" . }}
- name: S3_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "pg-duckdb.s3SecretName" . }}
      key: {{ include "pg-duckdb.s3SecretAccessKeyKey" . }}
{{- end }}
{{- end }}

{{- define "pg-duckdb.volumeMounts" -}}
- name: data
  mountPath: /var/lib/postgresql/data
{{- end }}

{{/*
Extra CLI args passed to postgres to declare shared_preload_libraries.
Command-line -c options are processed last and override postgresql.auto.conf,
so this guarantees the value is always what the chart declares regardless of
any prior ALTER SYSTEM writes.
*/}}
{{- define "pg-duckdb.preloadArgs" -}}
{{- $libs := prepend .Values.extensions.sharedPreloadLibraries "pg_duckdb" | uniq }}
- "-c"
- "shared_preload_libraries={{ join "," $libs }}"
{{- end }}

{{- define "pg-duckdb.probes" -}}
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

{{- define "pg-duckdb.exporter" -}}
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
          name: {{ include "pg-duckdb.secretName" . }}
          key: {{ include "pg-duckdb.passwordKey" . }}
  {{- with .Values.metrics.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}

{{- define "pg-duckdb.postgrest.jwtSecretName" -}}
{{- if .Values.postgrest.jwt.existingSecret.name }}
{{- .Values.postgrest.jwt.existingSecret.name }}
{{- else }}
{{- include "pg-duckdb.fullname" . }}-postgrest
{{- end }}
{{- end }}

{{- define "pg-duckdb.postgrest.jwtSecretKey" -}}
{{- if .Values.postgrest.jwt.existingSecret.name }}
{{- .Values.postgrest.jwt.existingSecret.key }}
{{- else }}
{{- "jwt-secret" }}
{{- end }}
{{- end }}
