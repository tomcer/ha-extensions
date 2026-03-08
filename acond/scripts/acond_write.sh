#!/bin/bash
# =============================================================================
# Acond TČ - wrapper pro HTTP POST zápis do Tecomat Foxtrot
# Použití: acond_write.sh <page> <post_data>
# Příklad: acond_write.sh PAGE49.XML "__R190_REAL_.1f=22.0"
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/acond_config.sh"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: Config file not found: $CONFIG_FILE" >&2
  echo "Copy acond_config.sh.example to acond_config.sh and fill in your values" >&2
  exit 1
fi

source "$CONFIG_FILE"

PAGE="$1"
POST_DATA="$2"

if [ -z "$PAGE" ] || [ -z "$POST_DATA" ]; then
  echo "Usage: $0 <page> <post_data>" >&2
  exit 1
fi

# Login and POST
curl -s -c /tmp/acond_cookies.txt \
  -d "USERNAME=${ACOND_USERNAME}&PASSWORD=${ACOND_PASSWORD}&SUBMIT=Login" \
  "http://${ACOND_HOST}/syswww/login.xml" > /dev/null && \
curl -s -b /tmp/acond_cookies.txt \
  -d "$POST_DATA" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  "http://${ACOND_HOST}/${PAGE}" > /dev/null
