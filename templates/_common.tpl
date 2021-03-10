{{- define "image_pull_secrets" -}}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
{{- if not (kindIs "string" .) }}
  - name: {{ $.Release.Name }}-pullsecret-{{ .name }}
{{- else }}
  - name: {{ . }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "image_pull_secrets.preRun" -}}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
{{- if not (kindIs "string" .) }}
  - name: {{ $.Release.Name }}-pullsecret-{{ .name }}-migrations
{{- else }}
  - name: {{ . }}-migrations
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}