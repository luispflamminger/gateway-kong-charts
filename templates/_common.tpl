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

{{- define "topologyKey" -}}
{{- if eq .Values.global.platform "caas" -}}
topology.kubernetes.io/zone
{{- else -}}
kubernetes.io/hostname
{{- end -}}
{{- end -}}

{{- define "platformSpecificValue" -}}
{{- $ := index . 0 }}
{{- $securityContextTemplate := printf "{{ %s | toYaml }}" (index . 2) }}
{{- with index . 1 }}
{{- $securityContextValue := tpl $securityContextTemplate $ }}
{{- if not (eq $securityContextValue "null") -}}
{{ $securityContextValue }}
{{- else if eq .Values.global.platform "caas" -}}
{{- $platformValues := $.Files.Get "platforms/caas.yaml" | fromYaml -}}
{{ tpl $securityContextTemplate (merge $ (dict "Values" $platformValues)) }}
{{- else -}}
{}
{{- end }}
{{- end }}
{{- end -}}