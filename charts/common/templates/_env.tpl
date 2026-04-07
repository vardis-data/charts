{{/*
S3 Environment Variables
Generates standard S3/object storage environment variables

Usage:
  env:
    {{- include "common.s3-env" . | nindent 4 }}

Required values:
  s3:
    enabled: true
    secretName: "my-s3-secret"
    region: "us-east-1"
    bucket: "my-bucket"
    endpoint: "https://s3.amazonaws.com"

Optional values:
  s3:
    envPrefix: "AWS_S3"           # defaults to AWS_S3
    accessKeyKey: "access-key"    # defaults to access-key
    secretKeyKey: "secret-key"    # defaults to secret-key
    forcePathStyle: "false"       # for MinIO/S3-compatible
*/}}
{{- define "common.s3-env" -}}
{{- if .Values.s3.enabled }}
{{- $prefix := .Values.s3.envPrefix | default "AWS_S3" }}
- name: {{ $prefix }}_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.s3.secretName | required ".Values.s3.secretName is required when s3.enabled is true" }}
      key: {{ .Values.s3.accessKeyKey | default "access-key" }}
- name: {{ $prefix }}_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.s3.secretName }}
      key: {{ .Values.s3.secretKeyKey | default "secret-key" }}
- name: {{ $prefix }}_REGION
  value: {{ .Values.s3.region | quote }}
- name: {{ $prefix }}_BUCKET
  value: {{ .Values.s3.bucket | quote }}
- name: {{ $prefix }}_ENDPOINT
  value: {{ .Values.s3.endpoint | quote }}
{{- if .Values.s3.forcePathStyle }}
- name: {{ $prefix }}_FORCE_PATH_STYLE
  value: {{ .Values.s3.forcePathStyle | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
SMTP Environment Variables
Generates standard SMTP environment variables

Usage:
  env:
    {{- include "common.smtp-env" . | nindent 4 }}

Required values:
  smtp:
    enabled: true
    host: "smtp.example.com"
    port: 587
    username: "user@example.com"
    secretName: "smtp-secret"

Optional values:
  smtp:
    passwordKey: "password"    # defaults to password
    secure: "true"             # TLS/SSL
*/}}
{{- define "common.smtp-env" -}}
{{- if .Values.smtp.enabled }}
- name: SMTP_HOST
  value: {{ .Values.smtp.host | required ".Values.smtp.host is required when smtp.enabled is true" | quote }}
- name: SMTP_PORT
  value: {{ .Values.smtp.port | required ".Values.smtp.port is required when smtp.enabled is true" | quote }}
- name: SMTP_USERNAME
  value: {{ .Values.smtp.username | required ".Values.smtp.username is required when smtp.enabled is true" | quote }}
- name: SMTP_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.smtp.secretName | required ".Values.smtp.secretName is required when smtp.enabled is true" }}
      key: {{ .Values.smtp.passwordKey | default "password" }}
{{- if .Values.smtp.secure }}
- name: SMTP_SECURE
  value: {{ .Values.smtp.secure | quote }}
{{- end }}
{{- if .Values.smtp.from }}
- name: SMTP_FROM
  value: {{ .Values.smtp.from | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Environment variable from Secret
Generates a single environment variable from a Kubernetes secret

Usage:
  env:
    - {{ include "common.env-secret" (dict "name" "MY_VAR" "secretName" "my-secret" "key" "my-key" "context" $) }}

Parameters:
  - name: Environment variable name
  - secretName: Name of the secret
  - key: Key in the secret
*/}}
{{- define "common.env-secret" -}}
name: {{ .name }}
valueFrom:
  secretKeyRef:
    name: {{ .secretName }}
    key: {{ .key }}
{{- end }}

{{/*
Environment variable from ConfigMap
Generates a single environment variable from a Kubernetes configmap

Usage:
  env:
    - {{ include "common.env-configmap" (dict "name" "MY_VAR" "configMapName" "my-cm" "key" "my-key" "context" $) }}

Parameters:
  - name: Environment variable name
  - configMapName: Name of the configmap
  - key: Key in the configmap
*/}}
{{- define "common.env-configmap" -}}
name: {{ .name }}
valueFrom:
  configMapKeyRef:
    name: {{ .configMapName }}
    key: {{ .key }}
{{- end }}
