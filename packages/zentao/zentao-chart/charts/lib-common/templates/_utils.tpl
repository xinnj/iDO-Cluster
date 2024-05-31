{{/* vim: set filetype=mustache: */}}
{{- /*
lib-common.util.merge will merge two YAML templates and output the result.
This takes an array of three values:
- the top context
- the template name of the overrides (destination)
- the template name of the base (source)
*/ -}}
{{- define "lib-common.util.mergeYaml" -}}
{{- $top := first . -}}
{{- $overrides := fromYaml (include (index . 1) $top) | default (dict ) -}}
{{- $tpl := fromYaml (include (index . 2) $top) | default (dict ) -}}
{{- toYaml (merge $overrides $tpl) -}}
{{- end -}}

{{- define "lib-common.util.mergeValues" -}}
{{- $top := first . -}}
{{- $libName := index . 1 -}}
{{- $libValues := (get $top.Values $libName) | default (dict) -}}
{{- $_ := merge $top.Values $libValues -}}
{{- end -}}

{{- define "lib-common.utils.generateResources" -}}
{{- if .Values.resources -}}
limits:
  {{- with .Values.resources }}
  {{- if .cpu }}
  cpu: {{ .cpu }}
  {{- end }}
  {{- if .memory }}
  memory: {{ .memory }}
  {{- end }}
  {{- end }}
requests:
  {{- if and .Values.global.allowOverSold .Values.oversold }}
    {{- with .Values.oversold }}
      {{- if .cpu }}
  cpu: {{ .cpu }}
      {{- end }}
      {{- if .memory }}
  memory: {{ .memory }}
      {{- end }}
    {{- end }}
  {{- else }}
    {{- with .Values.resources }}
      {{- if .cpu }}
  cpu: {{ .cpu }}
      {{- end }}
      {{- if .memory }}
  memory: {{ .memory }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}
{{- end -}}

{{/*
Usage: include "lib-common.utils.generateResources.v2" (dict "resources" dict "oversold" dict "values" .Values "ctx" .)
*/}}
{{- define "lib-common.utils.generateResources.v2" -}}
{{- if .resources -}}
 {{- if eq "on" (default .values.global.switchLimit .resources.switchLimit) }}
limits:
  {{- with .resources }}
  {{- if .cpu }}
  cpu: {{ .cpu }}
  {{- end }}
  {{- if .memory }}
  memory: {{ .memory }}
  {{- end }}
  {{- end }}
 {{- end }}
requests:
  {{- if and .values.global.allowOverSold .oversold }}
    {{- with .oversold }}
      {{- if .cpu }}
  cpu: {{ .cpu }}
      {{- end }}
      {{- if .memory }}
  memory: {{ .memory }}
      {{- end }}
    {{- end }}
  {{- else }}
    {{- with .resources }}
      {{- if .cpu }}
  cpu: {{ .cpu }}
      {{- end }}
      {{- if .memory }}
  memory: {{ .memory }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}
{{- end -}}

{{- define "lib-common.utils.replicas" -}}
{{- if or .Values.global.stoped .Values.global.stopped -}}
{{- 0 -}}
{{- else -}}
{{- .Values.replicas -}}
{{- end -}}
{{- end -}}

{{/*
Usage: include "lib-common.utils.replicas.v2" (dict "values" .Values "ctx" .)
*/}}
{{- define "lib-common.utils.replicas.v2" -}}
{{- if or .values.global.stoped .values.global.stopped -}}
{{- 0 -}}
{{- else -}}
{{- .values.replicas -}}
{{- end -}}
{{- end -}}

{{/*
Renders a value that contains template.
Usage:
{{ include "common.utils.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "lib-common.utils.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}


{{/*
Gets a value from .Values given
Usage:
{{ include "lib-common.utils.getValueByPath" (dict "path" "path" "ctx" $) }}
example: A.B.C
A and B must be map
A is nil, render fail
B is nil, return ""
C is not exist, return ""
*/}}
{{- define "lib-common.utils.getValueByPath" -}}
{{- $splitKeys := splitList "." .path -}}
{{- $frameCount := len $splitKeys -}}
{{- $value := "" -}}
{{- $latestObj := $.ctx.Values -}}
{{- range $index, $frame := $splitKeys -}}
  {{- if not $latestObj -}}
    {{- if lt (add $index 1) $frameCount -}}
      {{- printf "please review the entire path of '%s' exists in values" $.path | fail -}}
    {{- else -}}
      {{- $value := "" -}}
    {{- end -}}
  {{- else -}}
    {{- $value = ( index $latestObj $frame ) -}}
    {{- $latestObj = $value -}}
  {{- end -}}
{{- end -}}
{{- printf "%v" (default "" $value) -}} 
{{- end -}}

{{/*
Read value from ref field
Usage {{ include "lib-common.utils.readRef" (dict "value" "value" "ctx" $) }}
*/}}
{{- define "lib-common.utils.readRef" -}}
{{- if and (kindIs "string" .value) (hasPrefix "$ref" .value) }}
  {{- $path := trimPrefix "$ref:" .value -}}
  {{ include "lib-common.utils.getValueByPath" (dict "path" $path "ctx" .ctx) }}
{{- else if and (kindIs "string" .value) (hasPrefix "{{" .value) }}
  {{- tpl .value .ctx }}
{{- else }}
{{- .value -}}
{{- end }}
{{- end -}}

{{/*
Usage: include "lib-common.utils.depServiceName.withOverride" (dict "condition" "path.to.field" "subchart" "" "default" "" "ctx" $)
*/}}
{{- define "lib-common.utils.depServiceName.withOverride" -}}
{{- if (include "lib-common.utils.getValueByPath" (dict "path" .condition "ctx" .ctx) ) -}}
  {{- if not .subchart }}
  {{- printf "subchart should not be blank" | fail -}}
  {{- end -}}
{{- include "app.dependency.fullname" (list .ctx .subchart) -}}
{{- else -}}
{{- include "lib-common.utils.readRef" (dict "value" .default "ctx" .ctx) -}}
{{- end -}}
{{- end -}}

{{/*
Usage: {{ include "lib-common.utils.readbool" (dict "value" "" "ctx" $) }}
return a string, like "true"
*/}}
{{- define "lib-common.utils.readbool" -}}
{{- if (kindIs "bool" .value) -}}
  {{- .value -}}
{{- else if (kindIs "string" .value) -}}
  {{- include "lib-common.utils.readRef" (dict "value" .value "ctx" .ctx) -}}
{{- end -}}
{{- end -}}

{{/*
Usage: {{ include "lib-common.utils.genHost" (dict "host" "" "port" "" "protocol" "" "ctx" .ctx )}}
*/}}
{{- define "lib-common.utils.genHost" -}}
{{- $u := "" -}}
{{- if contains "://" .host }}
  {{- $u = .host }}
{{- else -}}
  {{- $u = printf "%s://%s" (default "https" .protocol) .host }}
{{- end -}}

{{- $withPort := regexMatch "^:\\d+$" $u -}}
{{- if and (not $withPort) .port -}}
  {{- $u }}:{{ .port -}}
{{- else -}}
  {{- $u -}}
{{- end -}}
{{- end -}}