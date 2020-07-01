{{- define "kong.labels" -}}
app: {{ .Chart.Name }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: kong
app.kubernetes.io/instance: kong-{{ include "prefixed_release_name" $ }}
app.kubernetes.io/component: api-gateway
app.kubernetes.io/part-of: {{ include "prefixed_release_name" $ }}
app.kubernetes.io/managed-by: {{ .Values.global.installed_by | default "tif" }}
{{ .Values.global.labels | toYaml }}
{{- end -}}

{{- define "kong.annotations.prometheus" -}}
prometheus.io/path: '{{ .Values.prometheus.path | default "/metrics" }}'
prometheus.io/scrape: 'true'
prometheus.io/port: '{{ .Values.prometheus.port | default 9542 }}'
{{- end -}}

{{- define "kong.isEnterprise" -}}
{{- if eq .Values.enterprise.license "" -}}
false
{{- else -}}
true
{{- end -}}
{{- end -}}

{{- define "kong.image" -}}
{{- if .Values.image -}}
{{ .Values.image }}
{{- else if eq (include "kong.isEnterprise" $ ) "true" -}}
'mtr.external.otc.telekomcloud.com/tif-public/kong-enterprise-edition:1.3.0.2-alpine'
{{- else -}}
'mtr.external.otc.telekomcloud.com/tif-public/kong:2.0.3-alpine'
{{- end -}}
{{- end -}}

{{- define "kong.selector" -}}
app.kubernetes.io/instance: kong-{{ include "prefixed_release_name" $ }}
{{- end -}}

{{- define "kong.bundledTrustedCaCertificates" }}
{{ include "kong.luaSslTrustedCertificates" $ }}
{{ .Values.trustedCaCertificates }}
{{ end -}}

{{- define "kong.checksums" -}}
{{- if or (eq .Values.sslVerify true) .Values.zipkin.luaSslTrustedCertificate }}
checksum/trusted-ca-certificates: {{ (include "kong.bundledTrustedCaCertificates" $ | default "# Set trustedCaCertificates in values.yaml") | sha256sum }}
{{- end -}}
{{- range .Values.templateChangeTriggers }}
checksum/{{ . }}: {{ include (print $.Template.BasePath "/" . ) $ | sha256sum }}
{{- end -}}
{{- end -}}

{{- define "kong.volumes" }}
- name: nginx-servers
  configMap:
    name: {{ .Release.Name }}-nginx-servers
{{- if or (eq .Values.sslVerify true) .Values.zipkin.luaSslTrustedCertificate .Values.postgres.externalDatabase.sslVerify }}
- name: trusted-ca-certificates
  secret:
    secretName: {{ .Release.Name }}-trusted-ca-certificates
{{- end -}}
{{- if .Values.defaultTlsSecret }}            
- name: server-certificate
  secret:
    secretName: {{ .Values.defaultTlsSecret }}
{{- end -}}
{{- end -}}

{{- define "kong.init.volumes" }}
{{- if .Values.postgres.externalDatabase.sslVerify }}
- name: lua-ssl-trusted-certificates
  secret:
    secretName: {{ .Release.Name }}-trusted-ca-certificates
    items:
      - key: lua-ssl-trusted-certificates.pem
        path: 'init/lua-ssl-trusted-certificates.pem'
{{- end -}}
{{- end -}}

{{- define "kong.init.volumeMounts" }}
{{- if .Values.postgres.externalDatabase.sslVerify }}
- name: lua-ssl-trusted-certificates
  mountPath: /usr/local/kong/tls
{{- end -}}
{{- end -}}

{{- define "kong.volumeMounts" }}
- name: nginx-servers
  mountPath: /usr/local/kong/nginx
{{- if or (eq .Values.sslVerify true) .Values.zipkin.luaSslTrustedCertificate .Values.postgres.externalDatabase.sslVerify }}
- name: trusted-ca-certificates
  mountPath: /usr/local/kong/tls
{{- end -}}
{{- if .Values.defaultTlsSecret }}            
- name: server-certificate
  mountPath: /usr/local/kong/default-https
{{- end -}}
{{- end -}}

{{- define "kong.nginx.directives" }}
- name: KONG_NGINX_HTTP_INCLUDE
  value: '/usr/local/kong/nginx/servers.conf'
{{- if .Values.defaultTlsSecret }}            
- name: KONG_SSL_CERT
  value: /usr/local/kong/default-https/tls.crt
- name: KONG_SSL_CERT_KEY
  value: /usr/local/kong/default-https/tls.key
{{- end }}
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

{{- define "kong.luaSslTrustedCertificates" }}
{{ .Values.zipkin.luaSslTrustedCertificate }}
{{ .Values.postgres.externalDatabase.luaSslTrustedCertificate }}
{{ end -}}

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

{{- define "kong.adminApi.url" -}}
{{- printf "https://%s" (include "kong.adminApi.host" . ) }}
{{- end -}}

{{- define "kong.adminApi.serviceHost" -}}
{{- printf "%s-admin.%s" .Release.Name .Release.Namespace }}
{{- end -}}

{{- define "kong.adminApi.serviceUrl" -}}
{{- $host := include "kong.adminApi.serviceHost" . -}}
{{- if .Values.adminApi.tls.enabled }}
{{- printf "https://%s:%s" $host "8444" }}
{{- else }}
{{- printf "http://%s:%s" $host "8001" }}
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

{{- define "kong.merged.adminApi.annotations" }}
{{- $globalAnnotations := dict "annotations" .Values.global.ingress.annotations | deepCopy -}}
{{- $localAnnotations := dict "annotations" .Values.adminApi.ingress.annotations -}}
{{- $mergedAnnotations := mergeOverwrite $globalAnnotations $localAnnotations }}
{{- $mergedAnnotations | toYaml -}}
{{ end -}}

{{- define "kong.merged.manager.annotations" }}
{{- $globalAnnotations := dict "annotations" .Values.global.ingress.annotations | deepCopy -}}
{{- $localAnnotations := dict "annotations" .Values.manager.ingress.annotations -}}
{{- $mergedAnnotations := mergeOverwrite $globalAnnotations $localAnnotations }}
{{- $mergedAnnotations | toYaml -}}
{{ end -}}

{{- define "kong.merged.portal.annotations" }}
{{- $globalAnnotations := dict "annotations" .Values.global.ingress.annotations | deepCopy -}}
{{- $localAnnotations := dict "annotations" .Values.portal.ingress.annotations -}}
{{- $mergedAnnotations := mergeOverwrite $globalAnnotations $localAnnotations }}
{{- $mergedAnnotations | toYaml -}}
{{ end -}}

{{- define "kong.merged.proxy.annotations" }}
{{- $globalAnnotations := dict "annotations" .Values.global.ingress.annotations | deepCopy -}}
{{- $localAnnotations := dict "annotations" .Values.proxy.ingress.annotations -}}
{{- $mergedAnnotations := mergeOverwrite $globalAnnotations $localAnnotations }}
{{- $mergedAnnotations | toYaml -}}
{{ end -}}
