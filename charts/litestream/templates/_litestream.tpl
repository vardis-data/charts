{{/*
Litestream enabled guard

Usage:
  {{- if include "litestream.enabled" . }}
  ...
  {{- end }}
*/}}
{{- define "litestream.enabled" -}}
{{- if .Values.litestream.enabled }}true{{- end }}
{{- end }}

{{/*
Litestream Secret
Contains S3 credentials for litestream replication

Usage:
  {{- include "litestream.secret" $ | nindent 0 }}

Required values:
  litestream:
    enabled: true
    s3:
      accessKeyId: "..."
      secretAccessKey: "..."

Optional values:
  litestream:
    secretName: "existing-secret"  # if set, this template renders nothing
*/}}
{{- define "litestream.secret" -}}
{{- if and .Values.litestream.enabled (not .Values.litestream.secretName) }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "common.fullname" . }}-litestream
  labels:
    {{- include "common.labels" . | nindent 4 }}
type: Opaque
stringData:
  LITESTREAM_ACCESS_KEY_ID: {{ .Values.litestream.s3.accessKeyId | quote }}
  LITESTREAM_SECRET_ACCESS_KEY: {{ .Values.litestream.s3.secretAccessKey | quote }}
{{- end }}
{{- end }}

{{/*
Litestream Secret Name
Returns the name of the Secret to use for litestream credentials

Usage:
  {{ include "litestream.secretName" . }}
*/}}
{{- define "litestream.secretName" -}}
{{- if .Values.litestream.secretName }}
{{- .Values.litestream.secretName }}
{{- else }}
{{- include "common.fullname" . }}-litestream
{{- end }}
{{- end }}

{{/*
Litestream ConfigMap
Contains the litestream.yml configuration

Usage:
  {{- include "litestream.configmap" $ | nindent 0 }}

Required values:
  litestream:
    enabled: true
    dbPath: "/data/db.sqlite3"
    s3:
      bucket: "my-bucket"
      path: "app/db.sqlite3"
      endpoint: "https://s3.amazonaws.com"
*/}}
{{- define "litestream.configmap" -}}
{{- if .Values.litestream.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common.fullname" . }}-litestream
  labels:
    {{- include "common.labels" . | nindent 4 }}
data:
  litestream.yml: |
    dbs:
      - path: {{ .Values.litestream.dbPath | default "/data/db.sqlite3" }}
        replicas:
          - url: s3://{{ .Values.litestream.s3.bucket }}/{{ .Values.litestream.s3.path }}
            endpoint: {{ .Values.litestream.s3.endpoint }}
{{- end }}
{{- end }}

{{/*
Litestream Init Container
Restores SQLite database from S3 replica before app starts

Usage in pod spec:
  initContainers:
    - {{- include "litestream.initContainer" $ | nindent 6 }}

Required values:
  litestream:
    enabled: true
    image:
      repository: litestream/litestream
      tag: "0.5"
    dbPath: "/data/db.sqlite3"

Volumes required:
  - name: data (mountPath: /data)
  - name: litestream-config (mountPath: /etc/litestream.yml, subPath: litestream.yml)
*/}}
{{- define "litestream.initContainer" -}}
name: litestream-restore
image: "{{ .Values.litestream.image.repository }}:{{ .Values.litestream.image.tag }}"
args:
  - restore
  - -if-replica-exists
  - -config
  - /etc/litestream.yml
  - {{ .Values.litestream.dbPath | default "/data/db.sqlite3" }}
env:
  - name: LITESTREAM_ACCESS_KEY_ID
    valueFrom:
      secretKeyRef:
        name: {{ include "litestream.secretName" . }}
        key: LITESTREAM_ACCESS_KEY_ID
  - name: LITESTREAM_SECRET_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: {{ include "litestream.secretName" . }}
        key: LITESTREAM_SECRET_ACCESS_KEY
volumeMounts:
  - name: data
    mountPath: /data
  - name: litestream-config
    mountPath: /etc/litestream.yml
    subPath: litestream.yml
{{- end }}

{{/*
Litestream Sidecar Container
Continuously replicates SQLite database to S3

Usage in pod spec:
  containers:
    - {{- include "litestream.sidecar" $ | nindent 6 }}

Required values:
  litestream:
    enabled: true
    image:
      repository: litestream/litestream
      tag: "0.5"

Optional values:
  litestream:
    resources:
      requests:
        cpu: 10m
        memory: 32Mi
      limits:
        cpu: 100m
        memory: 128Mi

Volumes required:
  - name: data (mountPath: /data)
  - name: litestream-config (mountPath: /etc/litestream.yml, subPath: litestream.yml)
*/}}
{{- define "litestream.sidecar" -}}
name: litestream
image: "{{ .Values.litestream.image.repository }}:{{ .Values.litestream.image.tag }}"
args:
  - replicate
  - -config
  - /etc/litestream.yml
{{- with .Values.litestream.resources }}
resources:
  {{- toYaml . | nindent 2 }}
{{- end }}
env:
  - name: LITESTREAM_ACCESS_KEY_ID
    valueFrom:
      secretKeyRef:
        name: {{ include "litestream.secretName" . }}
        key: LITESTREAM_ACCESS_KEY_ID
  - name: LITESTREAM_SECRET_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: {{ include "litestream.secretName" . }}
        key: LITESTREAM_SECRET_ACCESS_KEY
volumeMounts:
  - name: data
    mountPath: /data
  - name: litestream-config
    mountPath: /etc/litestream.yml
    subPath: litestream.yml
{{- end }}

{{/*
Litestream Volumes
Returns the volume specs needed by litestream (data + litestream-config)

Usage in pod spec:
  volumes:
    {{- include "litestream.volumes" $ | nindent 4 }}

Note: the consuming chart must still provide the `data` volume (PVC or emptyDir).
This helper only provides the `litestream-config` volume referencing the ConfigMap.
*/}}
{{- define "litestream.volumes" -}}
{{- if .Values.litestream.enabled }}
- name: litestream-config
  configMap:
    name: {{ include "common.fullname" . }}-litestream
{{- end }}
{{- end }}
