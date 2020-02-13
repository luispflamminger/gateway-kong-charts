{{- define "prefixed_release_name" -}}
  {{- .Values.global.project_prefix | default "tif-" }}{{ .Release.Name -}}
{{- end -}}

{{- define "postgresql.labels" -}}
app: {{ .Chart.Name }}
app.kubernetes.io/name: postgresql
app.kubernetes.io/instance: postgresql-{{ include "prefixed_release_name" $ }}
app.kubernetes.io/component: database
app.kubernetes.io/part-of: {{ include "prefixed_release_name" $ }}
app.kubernetes.io/managed-by: {{ .Values.global.installed_by | default "tif" }}
{{- end -}}

{{- define "kong.labels" -}}
app: {{ .Chart.Name }}
app.kubernetes.io/name: kong
app.kubernetes.io/instance: kong-{{ include "prefixed_release_name" $ }}
app.kubernetes.io/component: api-gateway
app.kubernetes.io/part-of: {{ include "prefixed_release_name" $ }}
app.kubernetes.io/managed-by: {{ .Values.global.installed_by | default "tif" }}
{{- end -}}

{{- define "kong.image" -}}
{{- if .Values.enterprise.enabled -}}
'kong:{{ .Values.version | default "latest" }}'
{{- else -}}
'mtr.external.otc.telekomcloud.com/tif/kong-ee:{{ .Values.version | default "latest" }}'
{{- end -}}
{{- end -}}

{{- define "postgresql.selector" -}}
app.kubernetes.io/instance: postgresql-{{ include "prefixed_release_name" $ }}
{{- end -}}

{{- define "kong.selector" -}}
app.kubernetes.io/instance: kong-{{ include "prefixed_release_name" $ }}
{{- end -}}