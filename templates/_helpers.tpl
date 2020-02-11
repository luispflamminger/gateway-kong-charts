{{- define "prefixed_release_name" -}}
  {{- .Values.global.project_prefix | default "tif-" }}{{ .Release.Name -}}
{{- end -}}

{{- define "postgresql.labels" -}}
app: {{ include "prefixed_release_name" $ }}
component: {{ .Chart.Name }}
chart: {{ .Chart.Name }}-{{ .Chart.Version }}
release: {{ include "prefixed_release_name" $ }}
installed_by: {{ .Values.global.installed_by | default "tif" }}
{{- end -}}

{{- define "kong.labels" -}}
app: {{ include "prefixed_release_name" $ }}
component: {{ .Chart.Name }}
chart: {{ .Chart.Name }}-{{ .Chart.Version }}
release: {{ include "prefixed_release_name" $ }}
installed_by: {{ .Values.global.installed_by | default "tif" }}
{{- end -}}