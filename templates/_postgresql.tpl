{{- define "postgresql.pvcName" -}}
{{- printf "%s-database-pvc" .Release.Name -}}
{{- end -}}
