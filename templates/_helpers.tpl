
{{- define "blazemeter-crane.fullname" -}}
{{- default .Chart.Name .Values.deployment.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "blazemeter-crane.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
    {{- default (include "blazemeter-crane.fullname" .) .Values.serviceAccount.name -}}
{{- else }}
    {{- default "default" .Values.serviceAccount.name -}}
{{ end }}
{{ end }}