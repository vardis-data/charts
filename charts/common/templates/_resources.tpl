{{/*
Secret Resource
Creates a Kubernetes Secret with base64-encoded data

Usage:
  {{- include "common.secret" . }}

Required values:
  secret:
    data:
      key1: "plaintext-value1"
      key2: "plaintext-value2"

Optional values:
  secret:
    annotations: {}
    stringData:              # For non-base64 encoded data
      key3: "value3"
*/}}
{{- define "common.secret" -}}
{{- if .Values.secret }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.secret.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
type: Opaque
{{- if .Values.secret.data }}
data:
  {{- range $key, $value := .Values.secret.data }}
  {{ $key }}: {{ $value | b64enc | quote }}
  {{- end }}
{{- end }}
{{- if .Values.secret.stringData }}
stringData:
  {{- toYaml .Values.secret.stringData | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
ConfigMap Resource
Creates a Kubernetes ConfigMap

Usage:
  {{- include "common.configmap" . }}

Required values:
  configMap:
    data:
      key1: "value1"
      key2: "value2"

Optional values:
  configMap:
    annotations: {}
    binaryData:
      file.bin: <base64-encoded-data>
*/}}
{{- define "common.configmap" -}}
{{- if .Values.configMap }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.configMap.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- if .Values.configMap.data }}
data:
  {{- toYaml .Values.configMap.data | nindent 2 }}
{{- end }}
{{- if .Values.configMap.binaryData }}
binaryData:
  {{- toYaml .Values.configMap.binaryData | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
ServiceAccount Resource
Creates a Kubernetes ServiceAccount

Usage:
  {{- include "common.serviceaccount" . }}

Required values:
  serviceAccount:
    create: true

Optional values:
  serviceAccount:
    name: "custom-sa-name"    # defaults to chart fullname
    annotations: {}
    automountServiceAccountToken: true
*/}}
{{- define "common.serviceaccount" -}}
{{- if .Values.serviceAccount.create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "common.serviceAccountName" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- if hasKey .Values.serviceAccount "automountServiceAccountToken" }}
automountServiceAccountToken: {{ .Values.serviceAccount.automountServiceAccountToken }}
{{- end }}
{{- end }}
{{- end }}

{{/*
ServiceAccount Name Helper
Returns the name of the ServiceAccount to use

Usage:
  serviceAccountName: {{ include "common.serviceAccountName" . }}
*/}}
{{- define "common.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "common.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
PersistentVolumeClaim Resource
Creates a Kubernetes PVC

Usage:
  {{- include "common.pvc" . }}

Required values:
  persistence:
    enabled: true
    size: "10Gi"

Optional values:
  persistence:
    existingClaim: "my-existing-pvc"  # if set, no PVC is created
    storageClass: "standard"
    accessMode: "ReadWriteOnce"       # defaults to ReadWriteOnce
    annotations: {}
*/}}
{{- define "common.pvc" -}}
{{- if and .Values.persistence.enabled (not .Values.persistence.existingClaim) }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with .Values.persistence.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  accessModes:
    - {{ .Values.persistence.accessMode | default "ReadWriteOnce" }}
  {{- if .Values.persistence.storageClass }}
  {{- if eq .Values.persistence.storageClass "-" }}
  storageClassName: ""
  {{- else }}
  storageClassName: {{ .Values.persistence.storageClass | quote }}
  {{- end }}
  {{- end }}
  resources:
    requests:
      storage: {{ .Values.persistence.size | required ".Values.persistence.size is required when persistence.enabled is true" }}
{{- end }}
{{- end }}

{{/*
HorizontalPodAutoscaler Resource
Creates a Kubernetes HPA for autoscaling

Usage:
  {{- include "common.hpa" . }}

Required values:
  autoscaling:
    enabled: true
    minReplicas: 1
    maxReplicas: 10

Optional values:
  autoscaling:
    targetCPUUtilizationPercentage: 80
    targetMemoryUtilizationPercentage: 80
    behavior: {}              # HPA scaling behavior
    metrics: []               # Custom metrics
*/}}
{{- define "common.hpa" -}}
{{- if .Values.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "common.fullname" . }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  metrics:
    {{- if .Values.autoscaling.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
    {{- end }}
    {{- if .Values.autoscaling.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetMemoryUtilizationPercentage }}
    {{- end }}
    {{- with .Values.autoscaling.metrics }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with .Values.autoscaling.behavior }}
  behavior:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
