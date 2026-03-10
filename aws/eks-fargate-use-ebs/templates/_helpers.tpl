{{/*
Expand the name of the chart.
*/}}
{{- define "eks-fargate-use-ebs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eks-fargate-use-ebs.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eks-fargate-use-ebs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "eks-fargate-use-ebs.labels" -}}
helm.sh/chart: {{ include "eks-fargate-use-ebs.chart" . }}
{{ include "eks-fargate-use-ebs.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "eks-fargate-use-ebs.selectorLabels" -}}
app.kubernetes.io/name: {{ include "eks-fargate-use-ebs.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "eks-fargate-use-ebs.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "eks-fargate-use-ebs.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Staging Common labels
*/}}
{{- define "staging-eks-fargate-use-ebs.labels" -}}
helm.sh/chart: {{ include "eks-fargate-use-ebs.chart" . }}
{{ include "staging-eks-fargate-use-ebs.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Staging Selector labels
*/}}
{{- define "staging-eks-fargate-use-ebs.selectorLabels" -}}
app.kubernetes.io/name: "staging-{{ include "eks-fargate-use-ebs.name" . }}"
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
