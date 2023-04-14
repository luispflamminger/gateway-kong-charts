{{- define "image_pull_secrets" -}}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
{{- if not (kindIs "string" .) }}
  - name: {{ $.Release.Name }}-{{ .name }}
{{- else }}
  - name: {{ . }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "database.host" -}}
  {{- if and (eq .Values.global.database.location "external") .Values.externalDatabase.host  -}}
    {{- .Values.externalDatabase.host -}}
  {{- else -}}
    {{ .Release.Name -}}-postgresql
  {{- end -}}
{{- end -}}

{{- define "platformSpecificValue" -}}
{{- $ := index . 0 }}
{{- $template := printf "{{ %s | toYaml }}" (index . 2) }}
{{- with index . 1 }}
{{- $value := tpl $template $ }}
{{- if not (eq $value "null") -}}
{{ $value }}
{{- else if eq .Values.global.platform "aws" -}}
{{- $platformValues := $.Files.Get "platforms/aws.yaml" | fromYaml -}}
{{ tpl $template (deepCopy $ | merge (dict "Values" $platformValues)) }}
{{- else if eq .Values.global.platform "caas" -}}
{{- $platformValues := $.Files.Get "platforms/caas.yaml" | fromYaml -}}
{{ tpl $template (deepCopy $ | merge (dict "Values" $platformValues)) }}
{{- end }}
{{- end }}
{{- end -}}