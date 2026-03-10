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

# Login (get fresh cookie, then POST credentials with new FW field names)
rm -f /tmp/acond_write_cookies.txt
curl -s --max-time 5 -L -c /tmp/acond_write_cookies.txt \
  "http://${ACOND_HOST}/syswww/login.xml" > /dev/null

curl -s --max-time 5 -b /tmp/acond_write_cookies.txt -c /tmp/acond_write_cookies.txt \
  -d "USER=${ACOND_USERNAME}&PASS=${ACOND_PASSWORD}" \
  "http://${ACOND_HOST}/syswww/login.xml" > /dev/null

# POST data
curl -s --max-time 5 -b /tmp/acond_write_cookies.txt \
  -d "$POST_DATA" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  "http://${ACOND_HOST}/${PAGE}" > /dev/null

rm -f /tmp/acond_write_cookies.txt
