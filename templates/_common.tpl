{{- define "prefixed_release_name" -}}
{{- .Values.global.project_prefix | default "tif-" }}{{ .Release.Name -}}
{{- end -}}

{{- define "image_pull_secrets" -}}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ $.Release.Name -}}-pullsecret-{{ .name }}
{{- end -}}
{{- end -}}
{{- end -}}