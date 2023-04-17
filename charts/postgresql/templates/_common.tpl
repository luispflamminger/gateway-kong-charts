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

{{- define "platformSpecificValue" -}}
{{- $ := index . 0 -}}
{{- $template := printf "{{ %s | toYaml }}" (index . 2) -}}
{{- with index . 1 -}}
{{- $value := tpl $template $ -}}

{{- if and (eq $value "null") -}}
{{- if eq .Values.global.platform "aws" -}}
{{- $platformValues := $.Files.Get "platforms/aws.yaml" | fromYaml -}}
{{ $value = tpl $template (mergeOverwrite (dict "Values" $platformValues) $) }}
{{- else if eq .Values.global.platform "caas" -}}
{{- $platformValues := $.Files.Get "platforms/caas.yaml" | fromYaml -}}
{{ $value = tpl $template (mergeOverwrite (dict "Values" $platformValues) $) }}
{{- end -}}
{{- end -}}

{{- if not (eq $value "null") -}}
{{ $value }}
{{- end -}}

{{- end -}}
{{- end -}}