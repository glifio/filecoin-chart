{{/* Expand the name of the chart */}}
{{- define "chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name 
fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name */}}
{{- define "chart.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Create chart name and version as used by the chart label */}}
{{- define "chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Common labels */}}
{{- define "chart.allLabels" -}}
{{ include "chart.selectorLabels" . }}
{{ include "chart.releaseLabels" . }}
{{- if .Values.labels }}
{{ toYaml .Values.labels }}
{{- end }}
{{- end -}}

{{/* "chart.releaseLabels" generates a list of common labels to be used across resources */}}
{{- define "chart.releaseLabels" -}}
helm.sh/chart: {{ include "chart.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- if .Values.release }}
{{ toYaml .Values.release }}
{{- end }}
{{- end }}

{{/* Selector labels */}}
{{- define "chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* "chart.jaegerTracingEnvvars" creates the envvars for supporting jaeger tracing */}}
{{- define "chart.jaegerTracingEnvvars" -}}
{{- if and .Values.jaeger .Values.jaeger.enabled }}
- name: JAEGER_AGENT_HOST
{{- if .Values.jaeger.host }}
  value: {{ .Values.jaeger.host }}
{{- else }}
  valueFrom:
    fieldRef:
      apiVersion: v1
      fieldPath: status.hostIP
{{- end }}
- name: JAEGER_AGENT_PORT
  value: {{ .Values.jaeger.port | default "6831" | quote }}
- name: JAEGER_SERVICE_NAME
  value: {{ .Values.jaeger.serviceName | default (include "sentinel-lily.instanceName" . ) | quote }}
- name: JAEGER_SAMPLER_TYPE
  value: {{ .Values.jaeger.sampler.type | default "probabilistic" | quote }}
- name: JAEGER_SAMPLER_PARAM
  value: {{ .Values.jaeger.sampler.param | default "0.0001" | quote }}
{{- end }}
{{- end }}

{{/* "chart.fingerprintAllArgs" accepts a set of args and returns a string fingerprint 
to uniquely identify that set. This is useful for automatically generating unique job names 
based on their input for later identification. */}}
{{/*
  Example:
    input: `--storage=db --confidence=100 --window=30s --tasks=blocks,messages,chaineconomics,actorstatesraw,actorstatespower,actorstatesreward,actorstatesmultisig,msapprovals`
    output: `s=db,c=100,w=30s,t=blmechSraSpoSreSmums,`
*/}}
{{- define "sentinel-lily.fingerprintAllArgs" -}}
{{- $fingerprint := "" }}
{{- range . }}
  {{- $t := lower (mustRegexReplaceAll "-+" . "") }}
  {{- /* Detect task list and handle fingerprinting specially */}}
  {{- if mustRegexMatch "^tasks=" $t }}
    {{- $taskList := trimPrefix "tasks=" $t }}
    {{- $taskFragment := "" }}
    {{- /* Split and range over tasklist split on `,` */}}
    {{- range (mustRegexSplit "," $taskList -1) }}
      {{- if mustRegexMatch "^actorstates" . }}
        {{- /* Detect `actorstates` tasks and prefix fragment w `S` to represent a task of this type in the fingerprint */}}
        {{- $taskFragment = printf "%sS%s" $taskFragment (trunc 2 (trimPrefix "actorstates" .)) }}
      {{- else }}
        {{- $taskFragment = printf "%s%s" $taskFragment (trunc 2 .) }}
      {{- end }}
    {{- end }}
    {{- $fingerprint = printf "%st=%s," $fingerprint $taskFragment }}
  {{- else }}
  {{- /* Otherwise, fingerprint w first letter of value before and value after */}}
    {{- $fragment := mustRegexReplaceAll "([a-z0-9])[a-z0-9]*(=?)([0-9]*[a-z]{0,2})" $t "${1}${2}${3}"  }}
    {{- $fingerprint = printf "%s%s," $fingerprint $fragment }}
  {{- end }}
{{- end }}
{{- $fingerprint }}
{{- end }}

{{/* "sentinel-lily.service-name-daemon-api" returns the full service name 
of the Lily daemon API endpoint. This is useful for DNS lookup of the API service. */}}
{{- define "chart.service-name-daemon-api" -}}
  {{- printf "%s-%s-%s" .Release.Name .Values.client "daemon-api" }}
{{- end }}
