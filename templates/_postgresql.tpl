{{- define "postgresql.labels" -}}
app: {{ .Release.Name }}
app.kubernetes.io/name: postgresql
app.kubernetes.io/instance: {{ .Release.Name }}-postgresql
app.kubernetes.io/component: database
app.kubernetes.io/part-of: tif-runtime
app.kubernetes.io/managed-by: {{ .Values.global.installed_by | default "tif" }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{ .Values.global.labels | toYaml }}
{{- end -}}

{{- define "postgresql.selector" -}}
app.kubernetes.io/instance: {{ .Release.Name }}-postgresql
{{- end -}}

{{- define "postgresql.image" -}}
{{- $imageName := "postgres" -}}
{{- $imageTag := "12.3-debian" -}}
{{- $imageRepository := "mtr.external.otc.telekomcloud.com" -}}
{{- $imageOrganization := "tif-public" -}}
{{- if .Values.postgres.image -}}
  {{- if not (kindIs "string" .Values.postgres.image) -}}
    {{ $imageRepository = .Values.postgres.image.repository | default $imageRepository -}}
    {{ $imageOrganization = .Values.postgres.image.organization | default $imageOrganization -}}
    {{ $imageName = .Values.postgres.image.name | default $imageName -}}
    {{ $imageTag = .Values.postgres.image.tag | default $imageTag -}}
    {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
  {{- else -}}
    {{- .Values.postgres.image -}}
  {{- end -}}
{{- else -}}
 {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
{{- end -}}
{{- end -}}

{{- define "postgresql.serviceName" -}}
{{ printf "%s-postgres" $.Release.Name }}
{{- end -}}

{{- define "postgresql.host" -}}
{{ .Values.postgres.host | default (printf "%s.%s" ( include "postgresql.serviceName" $ ) $.Release.Namespace) }}
{{- end -}}
