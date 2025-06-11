
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

{{/*
Return the role name: use .Values.deployment.role if set, else use the default {{ .Release.Name }}-role.
*/}}
{{- define "crane.roleName" }}
{{- if .Values.deployment.role }}
{{- .Values.deployment.role }}
{{- else }}
{{- printf "%s-role" .Release.Name }}
{{- end }}
{{- end }}

{{- define "crane.clusterroleName" }}
{{- if .Values.deployment.clusterrole }}
{{- .Values.deployment.clusterrole }}
{{- else }}
{{- printf "%s-clusterrole" .Release.Name }}
{{- end }}
{{- end }}