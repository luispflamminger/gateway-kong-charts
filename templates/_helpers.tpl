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

{{- define "kong.isEnterprise" -}}
{{- if contains "changeme" .Values.enterprise.license }}
false
{{- else -}}
true
{{- end -}}
{{- end -}}

{{- define "kong.image" -}}
{{- if .Values.image -}}
{{ .Values.image }}
{{- else if eq (include "kong.isEnterprise" $ ) "true" -}}
'mtr.external.otc.telekomcloud.com/tif/kong-ee-tif-plugin-mtls-auth:1.3.0.2-alpine'
{{- else -}}
'mtr.external.otc.telekomcloud.com/tif/kong:ce_2.0.0-alpine'
{{- end -}}
{{- end -}}

{{- define "postgres.image" -}}
{{- if .Values.postgres.image -}}
{{ .Values.postgres.image }}
{{- else if eq .Values.global.platform "openshift" -}}
'mtr.external.otc.telekomcloud.com/tifpackages/postgresql-96-centos7:master'
{{- else -}}
'postgres:9.6'
{{- end -}}
{{- end -}}

{{- define "postgresql.selector" -}}
app.kubernetes.io/instance: postgresql-{{ include "prefixed_release_name" $ }}
{{- end -}}

{{- define "postgresql.host" -}}
{{- if and .Values.externalDatabase (eq .Values.externalDatabase.enabled true) -}}
{{ .Values.externalDatabase.host }}
{{- else -}}
{{ .Release.Name }}-postgresql.{{ .Release.Namespace }}.svc.cluster.local
{{- end -}}
{{- end -}}

{{- define "postgresql.port" -}}
{{- if and .Values.externalDatabase (eq .Values.externalDatabase.enabled true) -}}
{{ (.Values.externalDatabase.port | default "5432") | atoi }}
{{- else -}}
{{ (.Values.postgres.port | default "5432") | atoi }}
{{- end -}}
{{- end -}}

{{- define "kong.selector" -}}
app.kubernetes.io/instance: kong-{{ include "prefixed_release_name" $ }}
{{- end -}}

{{- define "kong.nginx.directives" -}}
{{- if eq .Values.sslVerify true }}
- name: KONG_NGINX_HTTP_PROXY_SSL_TRUSTED_CERTIFICATE
  value: '/usr/local/kong/tif/trusted-ca-certificates.pem'
- name: KONG_NGINX_HTTP_PROXY_SSL_VERIFY
  value: 'on'
- name: KONG_NGINX_HTTP_PROXY_SSL_VERIFY_DEPTH
  value: '{{ .Values.sslVerifyDepth | default '1' }}'
{{- end }}
{{- if eq .Values.disableUpstreamCache true }}
# See: : https://github.com/openresty/lua-resty-core/pull/276/files#diff-c6d3d61f52132e153660e7832e95b88aR340-R349
- name: KONG_NGINX_HTTP_UPSTREAM_KEEPALIVE
  value: 'NONE'
{{- end -}}
{{- end -}}