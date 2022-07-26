{{- define "postgresql.labels" -}}
app: {{ .Release.Name }}
app.kubernetes.io/name: postgresql
app.kubernetes.io/instance: {{ .Release.Name }}-postgresql
app.kubernetes.io/component: database
app.kubernetes.io/part-of: tif-runtime
{{ .Values.global.labels | toYaml }}
{{- end -}}

{{- define "postgresql.selector" -}}
app.kubernetes.io/instance: {{ .Release.Name }}-postgresql
{{- end -}}

{{- define "postgresql.image" -}}
{{- $imageName := "postgres" -}}
{{- $imageTag := "12.3-debian" -}}
{{- $imageRepository := .Values.global.image.repository -}}
{{- $imageOrganization := .Values.global.image.organization -}}
{{- if .Values.postgres.image -}}
  {{- if not (kindIs "string" .Values.postgres.image) -}}
    {{ $imageRepository = .Values.postgres.image.repository | default $imageRepository -}}
    {{ $imageOrganization = .Values.postgres.image.organization | default $imageOrganization -}}
    {{ $imageName = .Values.postgres.image.name | default $imageName -}}
    {{ $imageTag = .Values.postgres.image.tag | default $imageTag -}}
    {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
  {{- else -}}
    {{- if .Values.global.image.force -}}
      {{- .Values.postgres.image | replace "mtr.devops.telekom.de" .Values.global.image.repository | replace "tardis-common" .Values.global.image.organization -}}
    {{- else -}}
      {{- .Values.postgres.image -}}
    {{- end -}}
  {{- end -}}
{{- else -}}
 {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
{{- end -}}
{{- end -}}

{{- define "postgresql.env" }}
- name: PGDATA
  value: {{ .Values.postgres.persistence.mountDir | default "/var/lib/postgresql/data" }}/pgdata
- name: POSTGRES_USER
  value: {{ .Values.postgres.user | default "kong" }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}
      key: postgresPassword
- name: POSTGRES_DB
  value: {{ .Values.postgres.database | default "kong" }}
# for centos and rhel we do have different environment variables
- name: POSTGRESQL_USER
  value: {{ .Values.postgres.user | default "kong" }}
- name: POSTGRESQL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}
      key: postgresPassword
- name: POSTGRESQL_DATABASE
  value: {{ .Values.postgres.database | default "kong" }}
{{- end -}}

{{- define "postgresql.serviceName" -}}
{{ printf "%s-postgres" $.Release.Name }}
{{- end -}}

{{- define "postgresql.host" -}}
{{ .Values.postgres.host | default (printf "%s.%s" ( include "postgresql.serviceName" $ ) $.Release.Namespace) }}
{{- end -}}
