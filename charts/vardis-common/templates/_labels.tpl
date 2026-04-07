{{/*
Common labels
*/}}
{{- define "vardis-common.labels" -}}
helm.sh/chart: {{ include "vardis-common.chart" . }}
{{ include "vardis-common.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "vardis-common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vardis-common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
