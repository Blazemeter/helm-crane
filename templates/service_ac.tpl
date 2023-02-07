{{/*
Create the name of the service account to use
*/}}

{{ define ".bm.serviceAccountName" }}
{{ if .Values.serviceAccount.create }}
    {{ default (include "bm.fullname" .) .Values.serviceAccount.name }}
{{ else }}
    {{ default "default" .Values.serviceAccount.name }}
{{ end }}
{{ end }}