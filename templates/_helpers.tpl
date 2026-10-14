
{{- define "blazemeter-crane.fullname" -}}
{{- default .Chart.Name .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "blazemeter-crane.serviceAccountName" -}}
{{- if .Values.deployment.serviceAccount.create }}
    {{- default (include "blazemeter-crane.fullname" .) .Values.deployment.serviceAccount.name -}}
{{- else }}
    {{- default "default" .Values.deployment.serviceAccount.name -}}
{{- end }}
{{- end }}

# Return the role name: use .Values.deployment.role if set, else use the default {{ .Release.Name }}-role.
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

# Returns the fully-qualified Crane image reference (repo:tag).
# Single source of truth, shared by the Deployment's image field and by
# imageOverridesJson, so the image Crane runs and the image the auto-updater
# treats as current can never diverge.
{{- define "helm-crane.craneImageRef" -}}
{{- $repo := .Values.imageOverride.craneImage | default "gcr.io/verdant-bulwark-278/blazemeter/crane" -}}
{{- $tag := "latest-master" -}}
{{- with .Values.imageOverride.tag -}}{{- $tag = . | toString -}}{{- end -}}
{{- printf "%s:%s" $repo $tag -}}
{{- end -}}

# This helper function returns the imageOverrides as a JSON object if set.
# When craneImage is set (i.e. a private registry), Crane's own image is added
# to the map under the key the updater looks up ("blazemeter/crane:latest").
# Without it the auto-updater falls back to DOCKER_REGISTRY and pulls Crane
# from the public registry, ignoring craneImage entirely.
{{- define "helm-crane.imageOverridesJson" -}}
{{- $nonEmpty := dict -}}
{{- range $k, $v := (.Values.imageOverride.executorImages | default dict) -}}
  {{- if $v -}}
    {{- $_ := set $nonEmpty $k $v -}}
  {{- end -}}
{{- end -}}
{{- if and .Values.imageOverride.craneImage (not (hasKey $nonEmpty "blazemeter/crane:latest")) -}}
  {{- $_ := set $nonEmpty "blazemeter/crane:latest" (include "helm-crane.craneImageRef" .) -}}
{{- end -}}
{{- $nonEmpty | toJson -}}
{{- end -}}
