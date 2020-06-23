{{- define "postgresql.labels" -}}
app: {{ .Chart.Name }}
app.kubernetes.io/name: postgresql
app.kubernetes.io/instance: postgresql-{{ include "prefixed_release_name" $ }}
app.kubernetes.io/component: database
app.kubernetes.io/part-of: {{ include "prefixed_release_name" $ }}
app.kubernetes.io/managed-by: {{ .Values.global.installed_by | default "tif" }}
{{ .Values.global.labels | toYaml }}
{{- end -}}

{{- define "postgres.image" -}}
{{- if .Values.postgres.image -}}
{{ .Values.postgres.image }}
{{- else if eq .Values.global.platform "openshift" -}}
'mtr.external.otc.telekomcloud.com/tif-public/postgresql-96-centos7:9.6'
{{- else -}}
'mtr.external.otc.telekomcloud.com/tif-public/postgres:9.6'
{{- end -}}
{{- end -}}

{{- define "postgresql.serviceName" -}}
{{ printf "%s-postgres" $.Release.Name }}
{{- end -}}

{{- define "postgresql.host" -}}
{{ .Values.postgres.host | default (printf "%s.%s.svc.cluster.local" ( include "postgresql.serviceName" $ ) $.Release.Namespace) }}
{{- end -}}

{{- define "postgresql.selector" -}}
app.kubernetes.io/instance: postgresql-{{ include "prefixed_release_name" $ }}
{{- end -}}

{{- define "postgresql.port" -}}
{{ ( .Values.postgres.port | default "5432") | atoi }}
{{- end -}}

{{- define "postgresql.database" -}}
{{ .Values.postgres.database | default "kong" }}
{{- end -}}

{{- define "postgresql.user" -}}
{{ .Values.postgres.user | default "kong" }}
{{- end -}}
