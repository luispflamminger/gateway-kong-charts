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
{{- if .Values.database.postgres.image -}}
  {{- if not (kindIs "string" .Values.database.postgres.image) -}}
    {{ $imageRepository = .Values.database.postgres.image.repository | default $imageRepository -}}
    {{ $imageOrganization = .Values.database.postgres.image.organization | default $imageOrganization -}}
    {{ $imageName = .Values.database.postgres.image.name | default $imageName -}}
    {{ $imageTag = .Values.database.postgres.image.tag | default $imageTag -}}
    {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
  {{- else -}}
    {{- if .Values.global.image.force -}}
      {{- .Values.database.postgres.image | replace "mtr.devops.telekom.de" .Values.global.image.repository | replace "tardis-common" .Values.global.image.organization -}}
    {{- else -}}
      {{- .Values.database.postgres.image -}}
    {{- end -}}
  {{- end -}}
{{- else -}}
 {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
{{- end -}}
{{- end -}}

{{- define "postgresql.env" }}
- name: PGDATA
  value: {{ .Values.database.postgres.persistence.mountDir | default "/var/lib/postgresql/data" }}/pgdata
- name: POSTGRES_USER
  value: {{ .Values.database.user | default "kong" }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}
      key: postgresPassword
- name: POSTGRES_DB
  value: {{ .Values.database.database | default "kong" }}
# for centos and rhel we do have different environment variables
- name: POSTGRESQL_USER
  value: {{ .Values.database.user | default "kong" }}
- name: POSTGRESQL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}
      key: postgresPassword
- name: POSTGRESQL_DATABASE
  value: {{ .Values.database.database | default "kong" }}
{{- end -}}

{{- define "postgresql.serviceName" -}}
{{ printf "%s-postgres" $.Release.Name }}
{{- end -}}
