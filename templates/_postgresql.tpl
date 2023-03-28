{{- define "postgresql.pvcName" -}}
{{- printf "%s-database-pvc" .Release.Name -}}
{{- end -}}


{{- define "postgresql.image" -}}
{{- $imageName := "postgres" -}}
{{- $imageTag := "12.3-debian" -}}
{{- $imageRepository := "mtr.devops.telekom.de" -}}
{{- $imageOrganization := "tardis-common" -}}
{{- if .Values.image -}}
  {{- if not (kindIs "string" .Values.image) -}}
    {{ $imageRepository = .Values.image.repository | default $imageRepository -}}
    {{ $imageOrganization = .Values.image.organization | default $imageOrganization -}}
    {{ $imageName = .Values.image.name | default $imageName -}}
    {{ $imageTag = .Values.image.tag | default $imageTag -}}
    {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
  {{- else -}}
    {{- if .Values.global.image.force -}}
      {{- .Values.image | replace "mtr.devops.telekom.de" .Values.global.image.repository | replace "tardis-common" .Values.global.image.organization -}}
    {{- else -}}
      {{- .Values.image -}}
    {{- end -}}
  {{- end -}}
{{- else -}}
 {{- printf "%s/%s/%s:%s" $imageRepository $imageOrganization $imageName $imageTag -}}
{{- end -}}
{{- end -}}