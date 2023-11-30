{{/*
Expand the name of the chart.
*/}}
{{- define "kafdrop.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kafdrop.fullname" -}}
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
{{- define "kafdrop.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kafdrop.labels" -}}
helm.sh/chart: {{ include "kafdrop.chart" . }}
{{ include "kafdrop.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ include "kafdrop.name" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kafdrop.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kafdrop.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kafdrop.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kafdrop.name" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Kafka Client Secret Name
*/}}
{{- define "kafka.client-connection-secret.name" }}
{{- $broker := .Values.kafka.broker | default "kafka" }}
{{- $secretName := printf "%s-client-secret" $broker }}
{{- $secretName }}
{{- end }}

{{/*
Kafka Client Secret Absent?
*/}}
{{- define "kafka.client-connection-secret.absent" }}
{{- $secretObj := (lookup "v1" "Secret" .Release.Namespace (include "kafka.client-connection-secret.name" . )) | default dict }}
{{- $output := "" }}
{{- if not $secretObj }}
{{- $output = "1" }}
{{- end }}
{{- $output }}
{{- end }}

{{/*
Kafka Client Secret Namespace
*/}}
{{- define "kafka.client-connection-secret.namespace" }}
{{- $output := "" }}
{{- if (include "kafka.client-connection-secret.absent" .) }}
{{- $output = .Values.kafka.namespace }}
{{- else }}
{{- $output = .Release.Namespace }}
{{- end }}
{{- $output }}
{{- end }}

{{/*
Kafka Bootstrap Server
*/}}
{{- define "kafka.bootstrap-server" }}
{{- $output := "" }}
{{- if .Values.kafka.bootstrapServer }}
{{- $output = .Values.kafka.bootstrapServer }}
{{- else }}
{{- $secretObj := (lookup "v1" "Secret" (include "kafka.client-connection-secret.namespace" .) (include "kafka.client-connection-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $bootstrapServer := (get $secretData "bootstrapServer") | b64dec }}
{{- $output = $bootstrapServer }}
{{- end }}
{{- $output }}
{{- end }}

{{/*
Kafka Client Authentication
*/}}
{{- define "kafka.authentication" }}
{{- $output := "" }}
{{- if .Values.kafka.clientId }}
{{- $output = "1" }}
{{- else }}
{{- $secretObj := (lookup "v1" "Secret" (include "kafka.client-connection-secret.namespace" .) (include "kafka.client-connection-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $clientId := (get $secretData "clientId") | b64dec }}
{{- if $clientId }}
{{- $output = "1" }}
{{- end }}
{{- end }}
{{- $output }}
{{- end }}

{{/*
Kafka Security Protocol
*/}}
{{- define "kafka.security-protocol" }}
{{- $output := "" }}
{{- if .Values.kafka.securityProtocol }}
{{- $output = .Values.kafka.securityProtocol }}
{{- else }}
{{- $secretObj := (lookup "v1" "Secret" (include "kafka.client-connection-secret.namespace" .) (include "kafka.client-connection-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $securityProtocol := (get $secretData "securityProtocol") | b64dec }}
{{- $output = $securityProtocol }}
{{- end }}
{{- $output }}
{{- end }}

{{/*
Kafka Sasl Mechanism
*/}}
{{- define "kafka.sasl-mechanism" }}
{{- $output := "" }}
{{- if .Values.kafka.saslMechanism }}
{{- $output = .Values.kafka.saslMechanism }}
{{- else }}
{{- $secretObj := (lookup "v1" "Secret" (include "kafka.client-connection-secret.namespace" .) (include "kafka.client-connection-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $saslMechanism := (get $secretData "saslMechanism") | b64dec }}
{{- $output = $saslMechanism }}
{{- end }}
{{- $output }}
{{- end }}

{{/*
Kafka Client Id
*/}}
{{- define "kafka.client-id" }}
{{- $output := "" }}
{{- if .Values.kafka.clientId }}
{{- $output = .Values.kafka.clientId }}
{{- else }}
{{- $secretObj := (lookup "v1" "Secret" (include "kafka.client-connection-secret.namespace" .) (include "kafka.client-connection-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $clientId := (get $secretData "clientId") | b64dec }}
{{- $output = $clientId }}
{{- end }}
{{- $output }}
{{- end }}

{{/*
Kafka Client secret
*/}}
{{- define "kafka.client-secret" }}
{{- $output := "" }}
{{- if .Values.kafka.clientSecret }}
{{- $output = .Values.kafka.clientSecret }}
{{- else }}
{{- $secretObj := (lookup "v1" "Secret" (include "kafka.client-connection-secret.namespace" .) (include "kafka.client-connection-secret.name" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $clientSecret := (get $secretData "clientSecret") | b64dec }}
{{- $output = $clientSecret }}
{{- end }}
{{- $output }}
{{- end }}

{{- define "kafdrop.properties" -}}
{{ include "kafka.security-protocol" . }}
{{ include "kafka.sasl-mechanism" . }}
{{- if eq (include "kafka.sasl-mechanism" .) "PLAIN" }}
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
    username="{{ include "kafka.client-id" . }}" \
    password="{{ include "kafka.client-secret" . }}";
{{- end }}
{{- if eq (include "kafka.sasl-mechanism" .) "SCRAM-SHA-512" }}
org.apache.kafka.common.security.scram.ScramLoginModule required\
    username="{{ include "kafka.client-id" . }}" \
    password="{{ include "kafka.client-secret" . }}";
{{- end }}
{{- end }}

{{- define "debezium.var-dump" }}
{{- . | mustToPrettyJson | printf "\nThe JSON output of the dumped var is: \n%s" | fail }}
{{- end }}