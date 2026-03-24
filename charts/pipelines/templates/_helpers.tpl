{{- define "pipeline.name" -}}
{{- required "pipeline.name is required" .Values.pipeline.name | replace "_" "-" }}
{{- end }}

{{- define "pipeline.datasetName" -}}
{{- .Values.pipeline.name | replace "-" "_" }}
{{- end }}

{{- define "pipeline.fullname" -}}
{{- include "pipeline.name" . }}
{{- end }}

{{- define "pipeline.configmapName" -}}
pipeline-{{ include "pipeline.name" . }}-variables
{{- end }}

{{- define "pipeline.imageName" -}}
{{- .Values.pipeline.image.repository }}/{{ include "pipeline.name" . }}:{{ .Values.pipeline.image.tag }}
{{- end }}

{{- define "pipeline.packageName" -}}
{{- include "pipeline.name" . }}
{{- end }}

{{- define "pipeline.workdir" -}}
/opt/pipelines/{{ include "pipeline.datasetName" . }}
{{- end }}

{{- define "pipeline.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ include "pipeline.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: pipeline
{{- end }}

{{- define "pipeline.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pipeline.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "pipeline.overwriteParquetFiles" -}}
{{- if .Values.pipeline.storage.overwriteParquetFiles }}1{{- else }}0{{- end }}
{{- end }}
