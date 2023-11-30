{{/*
Expand the name of the chart.
*/}}
{{- define "debezium.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "debezium.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "debezium.labels" -}}
helm.sh/chart: {{ include "debezium.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Database password
*/}}
{{- define "db.admin.password" -}}
{{- $namespace := .Release.Namespace }}
{{- $output := "" }}
{{- if (.Values.connector.database.password) }}
{{- $output = .Values.connector.database.password }}
{{- else }}
{{- $hostname := (split "." .Values.connector.database.hostname) }}
{{- $secret := $hostname._0 }}
{{- if ($hostname._1) }}
{{- $namespace = $hostname._1 }}
{{- end }}
{{- $secretObj := (lookup "v1" "Secret" $namespace $secret) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- $password := (get $secretData "database-admin-password") | b64dec }}
{{- $output = $password }}
{{- end }}
{{- $output }}
{{- end }}

{{/*
Kafka Connect
*/}}
{{- define "debezium.kafka-connect-name" -}}
{{- $output := "" }}
{{- if (.Values.connector.kafkaConnect) }}
{{- $output = .Values.connector.kafkaConnect }}
{{- else }}
{{- $kc := (lookup "kafka.strimzi.io/v1beta2" "KafkaConnect" .Release.Namespace "").items | first | default dict }}
{{- $mt := (get $kc "metadata") }}
{{- $output = (get $mt "name") }}
{{- end }}
{{- $output }}
{{- end }}

{/*
ArgoCD Syncwave
*/}}
{{- define "debezium.argocd-syncwave" -}}
{{- if .Values.argocd }}
{{- if and (.Values.argocd.syncwave) (.Values.argocd.enabled) -}}
argocd.argoproj.io/sync-wave: "{{ .Values.argocd.syncwave }}"
{{- else }}
{{- "{}" }}
{{- end }}
{{- else }}
{{- "{}" }}
{{- end }}
{{- end }}

{{/* 
Debugging

Use in combination with template rendering in the template:

{{- $myVar := (include "db.admin.password" $value) }}
{{- template "debezium.var-dump" $myVar }}

*/}}
{{- define "debezium.var-dump" }}
{{- . | mustToPrettyJson | printf "\nThe JSON output of the dumped var is: \n%s" | fail }}
{{- end }}