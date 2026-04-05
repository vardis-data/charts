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
{{- if .Values.existingSecret.enabled }}
{{- .Values.existingSecret.name }}
{{- else }}
{{- include "pg-duckdb.fullname" . }}
{{- end }}
{{- end }}

{{- define "pg-duckdb.passwordKey" -}}
{{- if .Values.existingSecret.enabled }}{{ .Values.existingSecret.keys.password }}{{ else }}password{{ end }}
{{- end }}

{{- define "pg-duckdb.s3AccessKeyIdKey" -}}
{{- if .Values.existingSecret.enabled }}{{ .Values.existingSecret.keys.s3AccessKeyId }}{{ else }}s3AccessKeyId{{ end }}
{{- end }}

{{- define "pg-duckdb.s3SecretAccessKeyKey" -}}
{{- if .Values.existingSecret.enabled }}{{ .Values.existingSecret.keys.s3SecretAccessKey }}{{ else }}s3SecretAccessKey{{ end }}
{{- end }}

{{- define "pg-duckdb.env" -}}
- name: PGDATA
  value: /var/lib/postgresql/data/pgdata
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "pg-duckdb.secretName" . }}
      key: {{ include "pg-duckdb.passwordKey" . }}
{{- if or .Values.s3.accessKeyId .Values.existingSecret.enabled }}
- name: S3_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ include "pg-duckdb.secretName" . }}
      key: {{ include "pg-duckdb.s3AccessKeyIdKey" . }}
- name: S3_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "pg-duckdb.secretName" . }}
      key: {{ include "pg-duckdb.s3SecretAccessKeyKey" . }}
{{- end }}
{{- end }}

{{- define "pg-duckdb.volumeMounts" -}}
- name: data
  mountPath: /var/lib/postgresql/data
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
