{{- define "kong.labels" -}}
app: {{ .Chart.Name }}
app.kubernetes.io/name: kong
app.kubernetes.io/instance: kong-{{ include "prefixed_release_name" $ }}
app.kubernetes.io/component: api-gateway
app.kubernetes.io/part-of: {{ include "prefixed_release_name" $ }}
app.kubernetes.io/managed-by: {{ .Values.global.installed_by | default "tif" }}
{{- end -}}

{{- define "kong.annotations.prometheus" }}
prometheus.io/path: '/metrics'
prometheus.io/scrape: 'true'
prometheus.io/port: '{{ .Values.prometheus.port | default 9542 }}'
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
'mtr.external.otc.telekomcloud.com/tif-public/tif-kong-ee:1.0.0-beta.1-1.3.0.2-alpine'
{{- else -}}
'mtr.external.otc.telekomcloud.com/tif-public/kong:2.0.3-alpine'
{{- end -}}
{{- end -}}

{{- define "kong.selector" -}}
app.kubernetes.io/instance: kong-{{ include "prefixed_release_name" $ }}
{{- end -}}

{{- define "kong.checksums" -}}
{{- if eq .Values.sslVerify true -}}
checksum/trusted-ca-certificates: {{ (.Values.trustedCaCertificates | default "# Set trustedCaCertificates in values.yaml") | sha256sum }}
{{- end -}}
{{- range .Values.templateChangeTriggers }}
checksum/{{ . }}: {{ include (print $.Template.BasePath "/" . ) $ | sha256sum }}
{{- end -}}
{{- end -}}

{{- define "kong.volumes" }}
- name: nginx-servers
  configMap:
    name: {{ .Release.Name }}-nginx-servers
{{- if eq .Values.sslVerify true }}
- name: trusted-ca-certificates
  secret:
    secretName: {{ .Release.Name }}-trusted-ca-certificates
{{- end -}}
{{- end -}}

{{- define "kong.volumeMounts" }}
- name: nginx-servers
  mountPath: /usr/local/kong/nginx
{{- if eq .Values.sslVerify true }}
- name: trusted-ca-certificates
  mountPath: /usr/local/kong/tls
{{- end -}}
{{- end -}}

{{- define "kong.nginx.directives" }}
- name: KONG_NGINX_HTTP_INCLUDE
  value: '/usr/local/kong/nginx/servers.conf'
{{- if eq .Values.sslVerify true }}
- name: KONG_NGINX_PROXY_PROXY_SSL_TRUSTED_CERTIFICATE
  value: '/usr/local/kong/tls/trusted-ca-certificates.pem'
- name: KONG_NGINX_PROXY_PROXY_SSL_VERIFY
  value: 'on'
- name: KONG_NGINX_PROXY_PROXY_SSL_VERIFY_DEPTH
  value: '{{ .Values.sslVerifyDepth | default '1' }}'
{{- end -}}
{{- if eq .Values.disableUpstreamCache true }}
# See: : https://github.com/openresty/lua-resty-core/pull/276/files#diff-c6d3d61f52132e153660e7832e95b88aR340-R349
- name: KONG_NGINX_HTTP_UPSTREAM_KEEPALIVE
  value: 'NONE'
{{- end -}}
{{- end -}}

{{- define "kong.customPlugins.env" -}}
{{ $enabledPlugins := "" }}
{{- range .Values.customPlugins -}}
{{ $enabledPlugins = printf "%s,%s" $enabledPlugins .name }}
{{- end }}
- name: KONG_PLUGINS
  value: bundled{{ $enabledPlugins }}
- name: KONG_LUA_PACKAGE_PATH
  value: "/opt/?.lua;;"
{{- end -}}

{{- define "kong.customPlugins.volumes" -}}
{{- range .Values.customPlugins }}
- name: kong-plugin-{{ .name }}
  configMap:
    name: {{ .configMap }}
{{- end -}}
{{- end -}}

{{- define "kong.customPlugins.volumeMounts" -}}
{{- range .Values.customPlugins }}
- name: kong-plugin-{{ .name }}
  mountPath: /opt/kong/plugins/{{ .name }}
{{- end -}}
{{- end -}}

{{- define "kong.adminApi.host" -}}
{{- if not (empty .Values.adminApi.ingress.hostname) }}
{{- .Values.adminApi.ingress.hostname -}}
{{- else }}
{{- printf "%s-admin-%s.%s" .Release.Name .Release.Namespace .Values.global.domain }}
{{- end -}}
{{- end -}}

{{- define "kong.manager.host" -}}
{{- if not (empty .Values.manager.ingress.hostname) }}
{{- .Values.manager.ingress.hostname -}}
{{- else }}
{{- printf "%s-manager-%s.%s" .Release.Name .Release.Namespace .Values.global.domain }}
{{- end -}}
{{- end -}}

{{- define "kong.portal.host" -}}
{{- if not (empty .Values.portal.ingress.hostname) }}
{{- .Values.portal.ingress.hostname -}}
{{- else }}
{{- printf "%s-portal-%s.%s" .Release.Name .Release.Namespace .Values.global.domain }}
{{- end -}}
{{- end -}}

{{- define "kong.proxy.host" -}}
{{- if not (empty .Values.proxy.ingress.hostname) }}
{{- .Values.proxy.ingress.hostname -}}
{{- else }}
{{- printf "%s-%s.%s" .Release.Name .Release.Namespace .Values.global.domain }}
{{- end -}}
{{- end -}}
