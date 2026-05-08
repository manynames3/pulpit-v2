{{- define "pulpit.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "pulpit.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := include "pulpit.name" . -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "pulpit.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" -}}
{{- end -}}

{{- define "pulpit.labels" -}}
helm.sh/chart: {{ include "pulpit.chart" . }}
app.kubernetes.io/name: {{ include "pulpit.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: pulpit-v2
pulpit.ai/tenant: {{ .Values.global.tenant | quote }}
{{- end -}}

{{- define "pulpit.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pulpit.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "pulpit.serviceAccountName" -}}
{{- if .Values.global.serviceAccount.create -}}
{{- default (printf "%s-workload" (include "pulpit.fullname" .)) .Values.global.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.global.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "pulpit.image" -}}
{{- printf "%s/%s:%s" .registry .repository .tag -}}
{{- end -}}
