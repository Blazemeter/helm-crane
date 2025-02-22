
{{- define "blazemeter-crane.fullname" -}}
{{- default .Chart.Name .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "blazemeter-crane.serviceAccountName" -}}
{{- if .Values.deployment.serviceAccount.create }}
    {{- default (include "blazemeter-crane.fullname" .) .Values.deployment.serviceAccount.name -}}
{{- else }}
    {{- default "default" .Values.deployment.serviceAccount.name -}}
{{ end }}
{{ end }}