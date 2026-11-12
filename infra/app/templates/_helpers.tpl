{{- define "lithium.labels" -}}
app: {{ .Chart.Name }}
dpoc.specpenguin.dev/platform: {{ .Values.dpoc.platform }}
dpoc.specpenguin.dev/service: {{ .Values.dpoc.service }}
dpoc.specpenguin.dev/landscape: {{ .Values.dpoc.landscape }}
{{- end -}}
{{- define "lithium.endpoint" -}}
{{ printf "https://lithium.aldehyde.%s.%s" .Values.dpoc.landscape (index .Values.dpoc.roots 0) }}
{{- end -}}
{{- define "lithium.adminEndpoint" -}}
{{ printf "https://admin.aldehyde.%s.%s" .Values.dpoc.landscape (index .Values.dpoc.roots 0) }}
{{- end -}}
