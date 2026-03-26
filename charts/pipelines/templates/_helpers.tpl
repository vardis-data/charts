{{- define "pipeline.name" -}}
{{- required "pipeline.name is required" .Values.pipeline.name | replace "_" "-" }}
{{- end }}

{{- define "pipeline.packageName" -}}
{{- if .Values.pipeline.imageName }}
{{- .Values.pipeline.imageName }}
{{- else }}
{{- .Values.pipeline.name | replace "-" "_" }}
{{- end }}
{{- end }}

{{- define "pipeline.datasetName" -}}
{{- if .Values.pipeline.datasetName }}
{{- .Values.pipeline.datasetName }}
{{- else }}
{{- include "pipeline.packageName" . }}
{{- end }}
{{- end }}

{{- define "pipeline.releaseName" -}}
{{- .Release.Name }}
{{- end }}

{{- define "pipeline.configmapName" -}}
pipeline-{{ include "pipeline.releaseName" . }}-variables
{{- end }}

{{- define "pipeline.jobName" -}}
{{- include "pipeline.releaseName" . }}-submit
{{- end }}

{{- define "pipeline.imageName" -}}
{{- if .Values.pipeline.imageName }}
{{- .Values.pipeline.image.repository }}/{{ .Values.pipeline.imageName }}:{{ .Values.pipeline.image.tag }}
{{- else }}
{{- .Values.pipeline.image.repository }}/{{ include "pipeline.packageName" . }}:{{ .Values.pipeline.image.tag }}
{{- end }}
{{- end }}

{{- define "pipeline.workdir" -}}
/opt/pipelines/{{ include "pipeline.packageName" . }}
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
