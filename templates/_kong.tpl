{{- define "kong.labels" -}}
app: {{ .Release.Name }}
app.kubernetes.io/name: kong
app.kubernetes.io/instance: {{ .Release.Name }}-kong
app.kubernetes.io/component: api-gateway
app.kubernetes.io/part-of: tif-runtime
{{ .Values.global.labels | toYaml }}
{{- end -}}

{{- define "kong.selector" -}}
app.kubernetes.io/instance: {{ .Release.Name }}-kong
{{- end -}}

{{- define "kong.image" -}}
{{- $imageName := "kong" -}}
{{- $imageTag := "2.3.2-alpine" -}}
{{- if eq (include "kong.isEnterprise" $ ) "true" -}}
{{- $imageName = "kong-enterprise-edition" -}}
{{- $imageTag = "1.3.0.2-alpine" -}}
{{- end -}}
{{- $imageRepository := "mtr.external.otc.telekomcloud.com" -}}
{{- $imageOrganization := "tif-public" -}}
{{- if .Values.image -}}
  {{- if not (kindIs "string" .Values.image) -}}
    {{ $imageRepository = .Values.image.repository | default $imageRepository -}}
    {{ $imageOrganization = .Values.image.organization | default $imageOrganization -}}
    {{ $imageName = .Values.image.name | default $imageName -}}
    {{ $imageTag = .Values.image.tag | default $imageTag -}}
    {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
  {{- else -}}
    {{- .Values.image -}}
  {{- end -}}
{{- else -}}
 {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
{{- end -}}
{{- end -}}

{{- define "kongplugins.image" -}}
{{- $imageName := "kong-plugins" -}}
{{- $imageTag := "1.0.0" -}}
{{- $imageRepository := "mtr.external.otc.telekomcloud.com" -}}
{{- $imageOrganization := "tif-public" -}}
{{- if .Values.plugins.initContainer.image -}}
  {{- if not (kindIs "string" .Values.plugins.initContainer.image) -}}
    {{ $imageRepository = .Values.plugins.initContainer.image.repository | default $imageRepository -}}
    {{ $imageOrganization = .Values.plugins.initContainer.image.organization | default $imageOrganization -}}
    {{ $imageName = .Values.plugins.initContainer.image.name | default $imageName -}}
    {{ $imageTag = .Values.plugins.initContainer.image.tag | default $imageTag -}}
    {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
  {{- else -}}
    {{- .Values.plugins.initContainer.image -}}
  {{- end -}}
{{- else -}}
 {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
{{- end -}}
{{- end -}}

{{- define "kong.isEnterprise" -}}
{{- if eq .Values.enterprise.license "" -}}
false
{{- else -}}
true
{{- end -}}
{{- end -}}

{{- define "kong.jumper.image" -}}
{{- $imageName := "jumper" -}}
{{- $imageTag := "1.3.1" -}}
{{- $imageRepository := "mtr.external.otc.telekomcloud.com" -}}
{{- $imageOrganization := "tif-public" -}}
{{- if .Values.jumper.image -}}
  {{- if not (kindIs "string" .Values.jumper.image) -}}
    {{ $imageRepository = .Values.jumper.image.repository | default $imageRepository -}}
    {{ $imageOrganization = .Values.jumper.image.organization | default $imageOrganization -}}
    {{ $imageName = .Values.jumper.image.name | default $imageName -}}
    {{ $imageTag = .Values.jumper.image.tag | default $imageTag -}}
    {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
  {{- else -}}
    {{- .Values.jumper.image -}}
  {{- end -}}
{{- else -}}
 {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
{{- end -}}
{{- end -}}

{{- define "kong.bundledTrustedCaCertificates" }}
{{ include "kong.luaSslTrustedCertificates" $ }}
{{ .Values.trustedCaCertificates }}
{{ end -}}

{{- define "kong.annotations" -}}
ops.eni.telekom.de/pipeline-meta-ref: {{ .Release.Name }}-pipeline-metadata
{{- if eq (toString .Values.global.metadata.pipeline.forceRedeploy) "true" }}
ops.eni.telekom.de/pipeline-force-redeploy: '{{ now | date "2006-01-02T15:04:05Z07:00" }}'
{{- end -}}
{{- end -}}

{{- define "kong.checksums" -}}
{{- if or (eq .Values.sslVerify true) .Values.zipkin.luaSslTrustedCertificate }}
checksum/trusted-ca-certificates: {{ (include "kong.bundledTrustedCaCertificates" $ | default "# Set trustedCaCertificates in values.yaml") | sha256sum }}
{{- end -}}
{{- range .Values.templateChangeTriggers }}
checksum/{{ . }}: {{ include (print $.Template.BasePath "/" . ) $ | sha256sum }}
{{- end -}}
{{- end -}}

{{- define "kong.isMigrationsBootstrap" -}}
{{- if .Values.migrations -}}
{{- if eq .Values.migrations "bootstrap" -}}
true
{{- end -}}
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "kong.isMigrationsUpgrade" -}}
{{- if .Values.migrations -}}
{{- if eq .Values.migrations "upgrade" -}}
true
{{- end -}}
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "kong.configuration.volumes" }}
- name: kong-configuration
  configMap:
    name: {{ .Release.Name }}-kong-admin-api
{{- end -}}

{{- define "kong.configuration.volumeMounts" }}
- name: kong-configuration
  mountPath: /tmp
{{- end -}}

{{- define "kong.migrations.volumes" }}
- name: kong-migrations-prefix-dir
  emptyDir: {}
- name: kong-migrations-tmp
  emptyDir: {}
{{- if .Values.postgres.externalDatabase.sslVerify }}
- name: lua-ssl-trusted-certificates
  secret:
    secretName: {{ .Release.Name }}-trusted-ca-certificates
    items:
      - key: lua-ssl-trusted-certificates.pem
        path: 'init/lua-ssl-trusted-certificates.pem'
{{- end -}}
{{- end -}}

{{- define "kong.migrations.volumeMounts" }}
- name: kong-migrations-prefix-dir
  mountPath: /kong
- name: kong-migrations-tmp
  mountPath: /tmp
{{- if .Values.postgres.externalDatabase.sslVerify }}
- name: lua-ssl-trusted-certificates
  mountPath: /opt/kong/tls
{{- end -}}
{{- end -}}

{{- define "kongplugins.volumes" }}
- name: kongplugins-tmp
  emptyDir: {}
{{- end -}}

{{- define "kongplugins.volumeMounts" }}
- name: local-luarocks
  mountPath: /home/kong/.luarocks
- name: kongplugins-tmp
  mountPath: /tmp
{{- end -}}

{{- define "kong.volumes" }}
- name: local-luarocks
  emptyDir: {}
- name: kong-prefix-dir
  emptyDir: {}
- name: kong-tmp
  emptyDir: {}
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

{{- define "kong.volumeMounts" }}
- name: local-luarocks
  mountPath: /home/kong/.luarocks
- name: kong-prefix-dir
  mountPath: /kong
- name: kong-tmp
  mountPath: /tmp
- name: nginx-servers
  mountPath: /opt/kong/nginx
{{- if or (eq .Values.sslVerify true) .Values.zipkin.luaSslTrustedCertificate .Values.postgres.externalDatabase.sslVerify }}
- name: trusted-ca-certificates
  mountPath: /opt/kong/tls
{{- end -}}
{{- if .Values.defaultTlsSecret }}            
- name: server-certificate
  mountPath: /opt/kong/default-https
{{- end -}}
{{- end -}}

{{- define "kong.jumper.volumes" }}
- name: kong-jumper-tmp
  emptyDir: {}
{{- end -}}

{{- define "kong.jumper.volumeMounts" }}
- name: kong-jumper-tmp
  mountPath: /tmp
{{- end -}}

{{- define "kong.nginx.directives" }}
- name: KONG_NGINX_WORKER_PROCESSES
  value: '{{ .Values.nginxWorkerProcesses | default "auto" }}'
- name: KONG_NGINX_HTTP_INCLUDE
  value: '/opt/kong/nginx/servers.conf'
{{- if .Values.defaultTlsSecret }}            
- name: KONG_SSL_CERT
  value: /opt/kong/default-https/tls.crt
- name: KONG_SSL_CERT_KEY
  value: /opt/kong/default-https/tls.key
{{- end }}
{{- if eq .Values.sslVerify true }}
- name: KONG_NGINX_PROXY_PROXY_SSL_TRUSTED_CERTIFICATE
  value: '/opt/kong/tls/trusted-ca-certificates.pem'
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

{{- define "kong.env.prefix" }}
- name: KONG_PREFIX
  value: /kong
{{- end -}}

{{- define "kong.env.enterprise.license" }}
- name: KONG_LICENSE_DATA
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}
      key: license
{{- end -}}

{{- define "kong.migrations.checkdatabase.env" }}
- name: PGHOST
  value: {{ include "postgresql.host" $ }}
- name: PGDATABASE
  value: {{ .Values.postgres.database }}
- name: PGUSER
  value: {{ .Values.postgres.user }}
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}
      key: postgresPassword
{{- end -}}

{{- define "kong.migrations.env" }}
- name: KONG_DATABASE
  value: postgres
{{- template "kong.env.prefix" . }}
{{- if eq .Values.rbac.enabled true }}
- name: KONG_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}
      key: kongAdminPassword
{{- end }}
- name: KONG_PG_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}
      key: postgresPassword
- name: KONG_PG_PORT
  value: '{{ .Values.postgres.port }}'
- name: KONG_PG_HOST
  value: '{{ include "postgresql.host" $ }}'
- name: KONG_PG_USER
  value: '{{ .Values.postgres.user }}'
- name: KONG_PG_DATABASE
  value: '{{ .Values.postgres.database }}'
{{- if eq .Values.postgres.externalDatabase.enabled true }}
{{- if .Values.postgres.externalDatabase.ssl }}
- name: KONG_PG_SSL
  value: 'on'
{{- if .Values.postgres.externalDatabase.sslVerify }}
- name: KONG_PG_SSL_VERIFY
  value: 'on'
- name: KONG_LUA_SSL_TRUSTED_CERTIFICATE
  value: '/opt/kong/tls/init/lua-ssl-trusted-certificates.pem'
{{- end }}
{{- end }}
{{- end }}
{{- if eq (include "kong.isEnterprise" $ ) "true" }}
{{- template "kong.env.enterprise.license" . }}
{{- end }}
{{- end -}}

{{- define "kong.env" }}
- name: KONG_MEM_CACHE_SIZE
  value: '{{ .Values.memCacheSize | default "128m" }}'
{{- template "kong.env.prefix" . }}
- name: KONG_DATABASE
  value: postgres
- name: KONG_PG_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}
      key: postgresPassword
- name: KONG_PG_PORT
  value: '{{ .Values.postgres.port }}'
- name: KONG_PG_HOST
  value: '{{ include "postgresql.host" $ }}'
- name: KONG_PG_USER
  value: '{{ .Values.postgres.user }}'
- name: KONG_PG_DATABASE
  value: '{{ .Values.postgres.database }}'
- name: KONG_PROXY_ACCESS_LOG
  value: {{ .Values.proxy.access_log | default "/dev/stdout" | quote }}
- name: KONG_PROXY_ERROR_LOG
  value: {{ .Values.proxy.error_log | default "/dev/stderr" | quote }}
{{- if eq .Values.postgres.externalDatabase.enabled true }}
{{- if .Values.postgres.externalDatabase.ssl }}
- name: KONG_PG_SSL
  value: 'on'
{{- if .Values.postgres.externalDatabase.sslVerify }}
- name: KONG_PG_SSL_VERIFY
  value: 'on'
{{- end }}
{{- end }}
{{- end }}
- name: KONG_NGINX_HTTP_SSL_PROTOCOLS
  value: "TLSv1.2 TLSv1.3"
- name: KONG_PROXY_LISTEN
{{- if .Values.proxy.tls.enabled }}
  value: '0.0.0.0:8443 ssl http2'
{{- else }}
  value: '0.0.0.0:8000'
{{- end -}}
{{- if .Values.adminApi.enabled }}
- name: KONG_ADMIN_LISTEN
{{- if .Values.adminApi.tls.enabled }}
  value: '0.0.0.0:8444 ssl'
{{- else }}
  value: '0.0.0.0:8001'
{{- end }}
- name: KONG_ADMIN_ACCESS_LOG
  value: {{ .Values.adminApi.access_log | default "/dev/stdout" | quote }}
- name: KONG_ADMIN_ERROR_LOG
  value: {{ .Values.adminApi.error_log | default "/dev/stderr" | quote }}
{{- end -}}
{{- if or .Values.zipkin.luaSslTrustedCertificate .Values.postgres.externalDatabase.sslVerify }}
- name: KONG_LUA_SSL_TRUSTED_CERTIFICATE
  value: '/opt/kong/tls/lua-ssl-trusted-certificates.pem'
{{- end }}
{{- if eq (include "kong.isEnterprise" $ ) "true" -}}
{{- template "kong.enterprise.env" . }}
{{- end -}}
{{- end -}}

{{- define "kong.enterprise.env" -}}
{{- if eq .Values.rbac.enabled true }}
- name: KONG_ENFORCE_RBAC
  value: 'on'
- name: KONG_ADMIN_GUI_AUTH
  value: 'basic-auth'
- name: KONG_ADMIN_GUI_SESSION_CONF
  value: '{"secret":"{{ .Values.manager.session.secret }}"}'
{{- end -}}
{{- if and (eq .Values.manager.enabled true) (eq (include "kong.adminApi.ingress.enabled" $) "true") }}
- name: KONG_ADMIN_API_URI
  value: 'https://{{ include "kong.adminApi.host" . }}'
- name: KONG_ADMIN_GUI_LISTEN
{{- if .Values.manager.tls.enabled }}
  value: '0.0.0.0:8445 ssl'
{{- else }}
  value: '0.0.0.0:8002'
{{- end }}
- name: KONG_ADMIN_GUI_URL
  value: 'https://{{ include "kong.manager.host" . }}'
- name: KONG_ADMIN_GUI_ACCESS_LOG
  value: {{ .Values.manager.access_log | default "/dev/stdout" | quote }}
- name: KONG_ADMIN_GUI_ERROR_LOG
  value: {{ .Values.manager.error_log | default "/dev/stderr" | quote }}
{{- end -}}
{{- if eq .Values.portal.enabled true }}
- name: KONG_PORTAL
  value: 'on'
{{- if .Values.portal.tls.enabled }}
- name: KONG_PORTAL_GUI_LISTEN
  value: '0.0.0.0:8446 ssl'
- name: KONG_PORTAL_API_LISTEN
  value: '0.0.0.0:8447 ssl'
{{- else }}
- name: KONG_PORTAL_GUI_LISTEN
  value: '0.0.0.0:8003'
- name: KONG_PORTAL_API_LISTEN
  value: '0.0.0.0:8004'
{{- end }}
- name: KONG_PORTAL_GUI_HOST
  value: '{{ include "kong.portal.host" . }}'
- name: KONG_PORTAL_GUI_PROTOCOL
  value: https
{{- if eq .Values.rbac.enabled true }}
- name: KONG_PORTAL_AUTH
  value: 'basic-auth'
- name: KONG_PORTAL_SESSION_CONF
  value: '{"secret":"{{ .Values.portal.session.secret }}"}'
- name: KONG_PORTAL_API_ACCESS_LOG
  value: {{ .Values.portal.access_log | default "/dev/stdout" | quote }}
- name: KONG_PORTAL_API_ERROR_LOG
  value: {{ .Values.portal.error_log | default "/dev/stderr" | quote }}
{{- end -}}
{{- end -}}
{{- template "kong.env.enterprise.license" . }}
{{- end -}}

{{- define "kong.jumper.env" }}
- name: JUMPER_ISSUER_URL
  value: {{ .Values.jumper.issuerUrl }}
{{- end -}}

{{- define "kong.customPlugins.env" -}}
{{ $enabledPlugins := "" }}
{{- range .Values.plugins.enabled -}}
{{ $enabledPlugins = printf "%s,%s" $enabledPlugins . }}
{{- end }}
- name: KONG_PLUGINS
  value: bundled{{ $enabledPlugins }}
- name: KONG_LUA_PACKAGE_PATH
  value: "/opt/?.lua;;"
{{- end -}}

{{- define "kong.adminApi.host" -}}
{{- if not (empty .Values.adminApi.ingress.hostname) }}
{{- .Values.adminApi.ingress.hostname -}}
{{- else }}
{{- printf "%s-admin-%s.%s" .Release.Name .Release.Namespace .Values.global.domain }}
{{- end -}}
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

{{- define "kong.adminApi.ingress.enabled" -}}
{{- if and .Values.adminApi.enabled (eq (include "kong.adminApi.ingressDefault" $) "true") }}
{{- printf "true" -}}
{{- else -}}
{{- printf "false" -}}
{{- end -}}
{{- end -}}

{{- define "kong.adminApi.ingressDefault" -}}
{{- if hasKey .Values.adminApi.ingress "enabled" }}
{{- printf "%s" (toString .Values.adminApi.ingress.enabled) -}}
{{- else -}}
{{- if eq (include "kong.isEnterprise" . ) "true" }}
{{- printf "true" -}}
{{- else -}}
{{- printf "false" -}}
{{- end -}}
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
