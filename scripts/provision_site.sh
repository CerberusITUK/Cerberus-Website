#!/usr/bin/env bash
# 20i Reseller API helper
#
# Examples:
#   STACKCP_TOKEN=xxxx ./scripts/provision_site.sh list-types | jq
#   STACKCP_TOKEN=xxxx ./scripts/provision_site.sh create-site example.com TYPE123 public_html "extra1.com,extra2.com"

set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required for this script" >&2
  exit 1
fi

usage() {
  cat <<'USAGE'
Usage:
  provision_site.sh list-types
  provision_site.sh create-site DOMAIN PACKAGE_TYPE [DOC_ROOT] [EXTRA_DOMAINS]

Environment:
  STACKCP_TOKEN       Raw API key from StackCP (Reseller Settings → API)
  STACKCP_API_BASE    Defaults to https://api.20i.com

Commands:
  list-types          Fetch /reseller/*/packageTypes to show available package type IDs
  create-site         Create a new site via /reseller/*/addWeb. EXTRA_DOMAINS is optional
                      and should be a comma-separated list (e.g. "www.example.com,shop.example.com").
USAGE
}

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 1
fi

API_BASE=${STACKCP_API_BASE:-"https://api.20i.com"}
TOKEN=${STACKCP_TOKEN:?"STACKCP_TOKEN is not set"}
AUTH_HEADER=$(printf %s "$TOKEN" | base64 | tr -d '\n')

call_api() {
  local method=$1
  local path=$2
  local data=${3:-}
  local url="${API_BASE}${path}"

  if [[ -z "$data" ]]; then
    curl -sS -X "$method" \
      -H "Authorization: Bearer ${AUTH_HEADER}" \
      -H "Accept: application/json" \
      "$url"
  else
    curl -sS -X "$method" \
      -H "Authorization: Bearer ${AUTH_HEADER}" \
      -H "Content-Type: application/json" \
      -H "Accept: application/json" \
      -d "$data" \
      "$url"
  fi
}

cmd=$1
shift

case "$cmd" in
  list-types)
    call_api GET "/reseller/*/packageTypes"
    ;;
  create-site)
    if [[ $# -lt 2 ]]; then
      echo "create-site requires DOMAIN and PACKAGE_TYPE" >&2
      usage >&2
      exit 1
    fi

    DOMAIN=$1
    PACKAGE_TYPE=$2
    DOC_ROOT=${3:-public_html}
    EXTRA_DOMAINS=${4:-}

    EXTRA_ARRAY=$(jq -n --arg extras "$EXTRA_DOMAINS" '
      if $extras | length == 0 then [] else
        ($extras
          | split(",")
          | map(
              gsub("^[\\s]+"; "")
              | gsub("[\\s]+$"; "")
              | select(length > 0)
            )
        )
      end')

    DOCROOT_MAP=$(jq -n --arg domain "$DOMAIN" --arg doc "$DOC_ROOT" '{($domain): $doc}')

    PAYLOAD=$(jq -n \
      --arg type "$PACKAGE_TYPE" \
      --arg domain "$DOMAIN" \
      --argjson extras "$EXTRA_ARRAY" \
      --argjson docroots "$DOCROOT_MAP" \
      '{
        type: $type,
        domain_name: $domain,
        extra_domain_names: $extras,
        documentRoots: $docroots
      }')

    call_api POST "/reseller/*/addWeb" "$PAYLOAD"
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    usage >&2
    exit 1
    ;;
esac
